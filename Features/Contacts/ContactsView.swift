//
//  ContactsView.swift
//  ContactsManager
//
//  Created by Ben Lu on 04/06/2022.
//

import Contacts
import CoreData
import SwiftUI

struct ContactsView: View {
  @State private var searchText = ""
  @StateObject var contactsContext = ContactsContext()

  var body: some View {
    NavigationView {
      List {
        ForEach(contactsContext.contactsMetaData.containers) { container in
          let groups = contactsContext.contactsMetaData.getGroupsByContainerId(
            containerId: container.id
          )
          ContainerGroupsSection(
            container: container, searchText: searchText, containerGroups: groups)
          ArchiveSection(containerId: container.id, searchText: searchText, containerGroups: groups)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Groups")
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
      //      .toolbar {
      //        ToolbarItemGroup(placement: .navigationBarTrailing) {
      //          EditButton()
      //        }
      //      }
      // TODO: Render all contacts
      Text("Select a Group")
    }
    .environmentObject(contactsContext)
  }
}

private struct ContainerGroupsSection: View {
  let container: CNContainer
  let searchText: String
  let containerGroups: [CNGroup]

  @EnvironmentObject var contactsContext: ContactsContext
  @Environment(\.managedObjectContext) private var moc
  @FetchRequest private var cdArchivedGroups: FetchedResults<CDArchivedGroups>
  @FetchRequest private var cdContactHashes: FetchedResults<CDContactHashes>

  init(container: CNContainer, searchText: String, containerGroups: [CNGroup]) {
    _cdContactHashes = FetchRequest<CDContactHashes>(
      sortDescriptors: [],
      predicate: NSPredicate(
        format: "containerId = %@", container.identifier
      ))
    _cdArchivedGroups = FetchRequest<CDArchivedGroups>(
      sortDescriptors: [],
      predicate: NSPredicate(
        format: "containerId = %@", container.identifier
      ))

    self.container = container
    self.searchText = searchText
    self.containerGroups = containerGroups
  }

  var body: some View {
    let archivedGroupIdsSet = getArchivedGroupIds()
    let groups = containerGroups.filter { !archivedGroupIdsSet.contains($0.identifier) }
    let allContacts = contactsContext.contactsMetaData.getContactsByContainerId(
      containerId: container.id)

    return Section {
      if hasSearchResults(groupName: String(localized: "All")) {
        let navigationTitle = String(localized: "All (\(allContacts.count))")
        ContactsNavView(
          contacts: allContacts,
          containerId: container.id,
          groups: groups,
          navigationTitle: navigationTitle,
          navigationTitleLabel: Text(navigationTitle).italic())
      }

      if hasSearchResults(groupName: String(localized: "Not grouped")) {
        let ungroupedContacts = contactsContext.contactsMetaData.getUngroupedContactsByContainerId(
          containerId: container.id)
        if ungroupedContacts.count > 0 {
          let navigationTitle = String(localized: "Not grouped (\(ungroupedContacts.count))")
          ContactsNavView(
            contacts: ungroupedContacts,
            containerId: container.id,
            groups: groups,
            navigationTitle: navigationTitle,
            navigationTitleLabel: Text(navigationTitle).italic())
        }
      }

      Recents(
        containerId: container.identifier, contacts: allContacts, groups: groups,
        isVisible: hasSearchResults(groupName: String(localized: "Recents")))

      ForEach(getSearchResults(groups: groups)) { group in
        let contacts = contactsContext.contactsMetaData.getContactsByGroupId(
          groupId: group.identifier)
        let navigationTitle = String(localized: "\(group.name) (\(contacts.count))")
        ContactsNavView(
          contacts: contacts, containerId: container.id, groups: groups,
          navigationTitle: navigationTitle,
          navigationTitleLabel: Text(navigationTitle),
          group: group
        )
      }
    } header: {
      Text(container.name)
    }
    .onAppear {
      handleContactHashesInit(
        cdContactHashes: cdContactHashes, contacts: allContacts, containerId: container.identifier)
    }
  }

  private func getArchivedGroupIds() -> Set<String> {
    Set(cdArchivedGroups.compactMap { $0.groupId })
  }

  /**
   * This is specifically used to render the "Recents" item
   * Note: https://forums.swift.org/t/psa-the-stdlib-now-uses-randomly-seeded-hash-values/10789/30
   * We specifically disable random seeding with an environment variable: SWIFT_DETERMINISTIC_HASHING=1
   */
  private func handleContactHashesInit(
    cdContactHashes: FetchedResults<CDContactHashes>, contacts: [CNContact], containerId: String
  ) {
    if !cdContactHashes.isEmpty {
      let contactIdHashMap = ContactHashData.getContactIdHashMap(cdContactHashes: cdContactHashes)
      contacts.forEach { contact in
        let contactHash = getHash(for: contact)
        if let contactHashData = contactIdHashMap[contact.identifier] {
          if contactHashData.contactHash != contactHash {
            // Hashes are different -> update hash and timestamp
            moc.performAndWait {
              let model = contactHashData.originalModel
              model.contactHash = Int64(contactHash)
              model.timestamp = Date()
              try? moc.save()
            }
          }
        } else {
          // Hashes doesn't exist -> create new hash with now timestamp
          let cdContactHash = CDContactHashes(context: moc)
          cdContactHash.contactId = contact.id
          cdContactHash.contactHash = Int64(contactHash)
          cdContactHash.containerId = containerId
          cdContactHash.timestamp = Date()
          try? moc.save()
        }
      }

      // Cleanup where contacts where deleted, but not deleted in CoreData
      let contactIds = Set(contacts.map { $0.identifier })
      let toDelete = contactIdHashMap.filter { (key, _) in !contactIds.contains(key) }
      if !toDelete.isEmpty {
        toDelete.forEach { moc.delete($0.value.originalModel) }
        try? moc.save()
      }
    } else {
      // No hashes exist -> create with nil timestamps (aka ignored initially)
      contacts.forEach { contact in
        let cdContactHash = CDContactHashes(context: moc)
        cdContactHash.contactId = contact.id
        cdContactHash.contactHash = Int64(getHash(for: contact))
        cdContactHash.containerId = containerId
        cdContactHash.timestamp = nil
      }
      try? moc.save()
    }
  }

  private func getSearchResults(groups: [CNGroup]) -> [CNGroup] {
    ContactsManager.getSearchResults(groups: groups, searchText: searchText)
  }
  private func hasSearchResults(groupName: String) -> Bool {
    if searchText.isEmpty {
      return true
    } else {
      let lowercasedSearchText = searchText.lowercased()
      return groupName.lowercased().contains(lowercasedSearchText)
    }
  }
}

private func getSearchResults(groups: [CNGroup], searchText: String) -> [CNGroup] {
  if searchText.isEmpty {
    return groups
  } else {
    let lowercasedSearchText = searchText.lowercased()
    return groups.filter { group in
      return group.name.lowercased().contains(lowercasedSearchText)
    }
  }
}

struct ArchiveSection: View {
  let containerId: String
  let searchText: String
  let containerGroups: [CNGroup]

  @FetchRequest private var cdArchivedGroups: FetchedResults<CDArchivedGroups>
  @State private var archiveExpanded: Bool = false
  @EnvironmentObject var contactsContext: ContactsContext
  @Environment(\.managedObjectContext) private var moc

  init(containerId: String, searchText: String, containerGroups: [CNGroup]) {
    _cdArchivedGroups = FetchRequest<CDArchivedGroups>(
      sortDescriptors: [],
      predicate: NSPredicate(
        format: "containerId = %@", containerId
      ))
    self.containerId = containerId
    self.searchText = searchText
    self.containerGroups = containerGroups

    handleCleanupGroupIds()
  }

  var body: some View {
    let archivedGroupIdsSet = getArchivedGroupIds()
    let groups = containerGroups.filter { archivedGroupIdsSet.contains($0.identifier) }
    let searchResults = ContactsManager.getSearchResults(groups: groups, searchText: searchText)

    if searchResults.count > 0 {
      DisclosureGroup(isExpanded: $archiveExpanded) {
        ForEach(searchResults) { group in
          let contacts = contactsContext.contactsMetaData.getContactsByGroupId(
            groupId: group.identifier)
          ContactsNavView(
            contacts: contacts, containerId: containerId, groups: groups,
            navigationTitle: "\(group.name) (\(contacts.count))", group: group,
            isArchived: true)
        }
      } label: {
        Text("Archived")
          .font(.subheadline)
          .foregroundColor(.gray)
          .bold()
      }
    }
  }

  private func getArchivedGroupIds() -> Set<String> {
    Set(cdArchivedGroups.compactMap { $0.groupId })
  }

  private func handleCleanupGroupIds() {
    let groupIdSet = Set(containerGroups.map { $0.identifier })
    let archivedGroupsToDelete = cdArchivedGroups.filter {
      if let groupId = $0.groupId {
        return !groupIdSet.contains(groupId)
      } else {
        return true
      }
    }
    if !archivedGroupsToDelete.isEmpty {
      archivedGroupsToDelete.forEach { moc.delete($0) }
      try? moc.save()
    }
  }
}

private struct Recents: View {
  let containerId: String
  let contacts: [CNContact]
  let groups: [CNGroup]
  let isVisible: Bool

  @Environment(\.managedObjectContext) private var moc

  @FetchRequest private var cdContactHashes: FetchedResults<CDContactHashes>

  init(containerId: String, contacts: [CNContact], groups: [CNGroup], isVisible: Bool) {
    _cdContactHashes = FetchRequest<CDContactHashes>(
      sortDescriptors: [],
      predicate: NSPredicate(
        format: "containerId = %@", containerId
      ))

    self.containerId = containerId
    self.contacts = contacts
    self.groups = groups
    self.isVisible = isVisible
  }

  var body: some View {
    let recentContacts = getRecentContacts()
    let navigationTitle = String(localized: "Recents (\(recentContacts.count))")
    if isVisible && !recentContacts.isEmpty && recentContacts.count != contacts.count {
      ContactsNavView(
        contacts: recentContacts, containerId: containerId, groups: groups,
        navigationTitle: navigationTitle,
        navigationTitleLabel: Text(navigationTitle).italic()
      )
    }
  }

  private func getRecentContacts() -> [CNContact] {
    // For some contacts, contactIdHashMap, get where found and timestamp is not nil and timestamp is recent
    let contactIdHashMap = ContactHashData.getContactIdHashMap(cdContactHashes: cdContactHashes)
    let recentThreshold = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
    return contacts.filter { contact in
      if let hashData = contactIdHashMap[contact.identifier], let timestamp = hashData.timestamp,
        timestamp > recentThreshold
      {
        return true
      }
      return false
    }.sorted {
      if let timestamp0 = contactIdHashMap[$0.identifier]?.timestamp,
        let timestamp1 = contactIdHashMap[$1.identifier]?.timestamp
      {
        return timestamp0 > timestamp1
      }
      return false
    }
  }
}

struct ContactHashData {
  let contactId: String
  let contactHash: Int
  let timestamp: Date?
  let originalModel: FetchedResults<CDContactHashes>.Element

  static func create(data: FetchedResults<CDContactHashes>.Element) -> ContactHashData? {
    if let contactId = data.contactId {
      return ContactHashData(
        contactId: contactId, contactHash: Int(data.contactHash), timestamp: data.timestamp,
        originalModel: data)
    }
    return nil
  }

}
extension ContactHashData {
  static func getContactIdHashMap(cdContactHashes: FetchedResults<CDContactHashes>)
    -> [String: ContactHashData]
  {
    Dictionary(
      uniqueKeysWithValues: cdContactHashes.compactMap {
        if let contactId = $0.contactId, let data = ContactHashData.create(data: $0) {
          return (contactId, data)
        }
        return nil
      })
  }
}

struct Contacts_Previews: PreviewProvider {
  static var previews: some View {
    ContactsView().environment(
      \.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
