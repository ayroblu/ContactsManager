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
  @FetchRequest(sortDescriptors: [])
  private var cdArchivedGroups: FetchedResults<CDArchivedGroups>
  @FetchRequest(sortDescriptors: [
    NSSortDescriptor(keyPath: \CDContactHashes.timestamp, ascending: false)
  ])
  private var cdContactHashes: FetchedResults<CDContactHashes>

  @State private var searchText = ""
  @StateObject var contactsContext = ContactsContext()

  var body: some View {
    NavigationView {
      List {
        ForEach(contactsContext.contactsMetaData.containers) { container in
          ContainerGroupsSection(container: container, searchText: searchText)
          ArchiveSection(containerId: container.id, searchText: searchText)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Contacts")
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

  @EnvironmentObject var contactsContext: ContactsContext
  @FetchRequest(sortDescriptors: []) private var cdArchivedGroups: FetchedResults<CDArchivedGroups>
  @Environment(\.managedObjectContext) private var moc
  @FetchRequest private var cdContactHashes: FetchedResults<CDContactHashes>

  init(container: CNContainer, searchText: String) {
    _cdContactHashes = FetchRequest<CDContactHashes>(
      sortDescriptors: [],
      predicate: NSPredicate(
        format: "containerId = %@", container.identifier
      ))

    self.container = container
    self.searchText = searchText
  }

  var body: some View {
    let archivedGroupIdsSet = getArchivedGroupIds()
    let groups = contactsContext.contactsMetaData.getGroupsByContainerId(
      containerId: container.identifier
    ).filter { !archivedGroupIdsSet.contains($0.identifier) }
    let allContacts = contactsContext.contactsMetaData.getContactsByContainerId(
      containerId: container.id)

    return Section {
      if hasSearchResults(groupName: "All") {
        let navigationTitle = "All (\(allContacts.count))"
        ContactsNav(
          contacts: allContacts,
          containerId: container.id,
          groups: groups,
          navigationTitle: navigationTitle,
          navigationTitleLabel: Text(navigationTitle).italic())
      }

      if hasSearchResults(groupName: "Not grouped") {
        let ungroupedContacts = contactsContext.contactsMetaData.getUngroupedContactsByContainerId(
          containerId: container.id)
        if ungroupedContacts.count > 0 {
          let navigationTitle = "Not grouped (\(ungroupedContacts.count))"
          ContactsNav(
            contacts: ungroupedContacts,
            containerId: container.id,
            groups: groups,
            navigationTitle: navigationTitle,
            navigationTitleLabel: Text(navigationTitle).italic())
        }
      }

      Recents(
        containerId: container.identifier, contacts: allContacts, groups: groups,
        isVisible: hasSearchResults(groupName: "Recents"))

      ForEach(getSearchResults(groups: groups)) { group in
        let contacts = contactsContext.contactsMetaData.getContactsByGroupId(
          groupId: group.identifier)
        let navigationTitle = "\(group.name) (\(contacts.count))"
        ContactsNav(
          contacts: contacts, containerId: container.id, groups: groups,
          navigationTitle: navigationTitle,
          navigationTitleLabel: Text(navigationTitle),
          group: group
        )
      }
      //      .onDelete { a in
      //        print(a)
      //      }
    } header: {
      Text(container.name)
    }
    .onAppear {
      handleContactHashesInit(
        cdContactHashes: cdContactHashes, contacts: allContacts, containerId: container.identifier)
    }
  }

  private func getArchivedGroupIds() -> Set<String> {
    // Container id?
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
    // TODO: Delete the items when a contact is deleted
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

  @FetchRequest(sortDescriptors: [])
  private var cdArchivedGroups: FetchedResults<CDArchivedGroups>

  @State private var archiveExpanded: Bool = false
  @EnvironmentObject var contactsContext: ContactsContext

  var body: some View {
    let archivedGroupIdsSet = getArchivedGroupIds()
    let groups = contactsContext.contactsMetaData.getGroupsByContainerId(
      containerId: containerId
    ).filter { archivedGroupIdsSet.contains($0.identifier) }
    let searchResults = ContactsManager.getSearchResults(groups: groups, searchText: searchText)

    if searchResults.count > 0 {
      DisclosureGroup(isExpanded: $archiveExpanded) {
        ForEach(searchResults) { group in
          let contacts = contactsContext.contactsMetaData.getContactsByGroupId(
            groupId: group.identifier)
          ContactsNav(
            contacts: contacts, containerId: containerId, groups: groups,
            navigationTitle: "\(group.name) (\(contacts.count))", group: group,
            isArchived: true)
          //            getNavigationLinksForContacts(
          //              contacts: contacts, container: container, groups: groups,
          //              navigationTitle: "\(group.name) (\(contacts.count))")
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
    // Container id?
    Set(cdArchivedGroups.compactMap { $0.groupId })
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
    let navigationTitle = "Recents (\(recentContacts.count))"
    if isVisible && !recentContacts.isEmpty && recentContacts.count != contacts.count {
      ContactsNav(
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

private struct ContactsNav: View {
  let contacts: [CNContact]
  let containerId: String
  let groups: [CNGroup]
  let navigationTitle: String
  var navigationTitleLabel: Text?
  var group: CNGroup?
  var isArchived: Bool = false

  @State private var isShowingEditAlert = false
  @State private var isShowingDeleteAlert = false
  @State private var alertInput = ""
  @EnvironmentObject var contactsContext: ContactsContext
  @Environment(\.managedObjectContext) private var moc
  @FetchRequest(sortDescriptors: [])
  private var cdArchivedGroups: FetchedResults<CDArchivedGroups>

  var body: some View {
    if let group = group {
      getLink()
        .textFieldAlert(isShowing: isShowingEditAlert) {
          TextFieldAlert(
            title: "Edit Group Name", message: "What would you like to call your Contact Group?",
            placeholder: "Group name...", initialInputText: group.name,
            onSave: { newName in
              editGroupNameSafe(group: group, name: newName)
              contactsContext.refresh()
            },
            isShowing: $isShowingEditAlert)
        }
        .swipeActions(edge: .leading) {
          Button("Edit") {
            alertInput = group.name
            isShowingEditAlert = true
          }
          .tint(.orange)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
          Button("Delete") {
            isShowingDeleteAlert = true
          }
          .tint(.red)
        }
        .swipeActions(edge: .trailing) {
          if isArchived {
            Button("Unarchive") {
              unarchiveGroup()
            }
            .tint(.orange)
          } else {
            Button("Archive") {
              archiveGroup()
            }
            .tint(.orange)
          }
        }
        .alert("Delete group \"\(group.name)\"?", isPresented: $isShowingDeleteAlert) {
          Button("Cancel", role: .cancel) {}
          Button("Confirm", role: .destructive) {
            withAnimation {
              deleteGroupSafe(group: group)
              contactsContext.refresh()
            }
          }
        }
    } else {
      getLink()
    }
  }

  private func getLink() -> some View {
    let navigationTitleText = navigationTitleLabel ?? Text(navigationTitle)
    return NavigationLink {
      ContactsListView(
        navigationTitle: navigationTitle, contacts: contacts, containerId: containerId,
        allGroups: groups)
    } label: {
      navigationTitleText
    }
  }

  private func archiveGroup() {
    if let group = group {
      withAnimation {
        let cdArchivedGroup = CDArchivedGroups(context: moc)
        cdArchivedGroup.groupId = group.identifier
        cdArchivedGroup.containerId = containerId
        try? moc.save()
      }
    }
  }
  private func unarchiveGroup() {
    if let group = group {
      let fetchRequest: NSFetchRequest<CDArchivedGroups> = CDArchivedGroups.fetchRequest()
      fetchRequest.predicate = NSPredicate(
        format: "groupId = %@", group.identifier
      )
      fetchRequest.fetchLimit = 1

      if let cdArchivedGroups = try? moc.fetch(fetchRequest), cdArchivedGroups.count > 0 {
        cdArchivedGroups.forEach(moc.delete)
        withAnimation {
          try? moc.save()
        }
      }
    }
  }
}

struct Contacts_Previews: PreviewProvider {
  static var previews: some View {
    ContactsView().environment(
      \.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
