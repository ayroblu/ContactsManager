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
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
    animation: .default)
  private var items: FetchedResults<Item>
  @State private var searchText = ""
  @StateObject var contactsContext = ContactsContext()

  var body: some View {
    NavigationView {
      List {
        ForEach(contactsContext.contactsMetaData.containers) { container in
          getSection(container: container)
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
      Text("Select a Contact")
    }
    // https://stackoverflow.com/questions/65316497/swiftui-navigationview-navigationbartitle-layoutconstraints-issue
    // .navigationViewStyle(StackNavigationViewStyle())
    .environmentObject(contactsContext)
  }

  private func getSection(container: CNContainer) -> some View {
    Section {
      let groups = contactsContext.contactsMetaData.getGroupsByContainerId(
        containerId: container.identifier)
      // getUngroupedContacts(forContainer: container, groups: groups)
      if hasSearchResults(groupName: "Not grouped") {
        let ungroupedContacts = contactsContext.contactsMetaData.getUngroupedContactsByContainerId(
          containerId: container.id)
        if ungroupedContacts.count > 0 {
          ContactsNav(
            contacts: ungroupedContacts,
            containerId: container.id,
            groups: groups,
            navigationTitle: "Not grouped (\(ungroupedContacts.count))")
        }
      }

      if hasSearchResults(groupName: "All") {
        let contacts = contactsContext.contactsMetaData.getContactsByContainerId(
          containerId: container.id)
        ContactsNav(
          contacts: contacts,
          containerId: container.id,
          groups: groups,
          navigationTitle: "All (\(contacts.count))")
      }

      ForEach(getSearchResults(groups: groups)) { group in
        let contacts = contactsContext.contactsMetaData.getContactsByGroupId(
          groupId: group.identifier)
        ContactsNav(
          contacts: contacts, containerId: container.id, groups: groups,
          navigationTitle: "\(group.name) (\(contacts.count))",
          group: group
        )
      }
      //      .onDelete { a in
      //        print(a)
      //      }
    } header: {
      Text(container.name)
    }
  }

  private func addItem() {
    withAnimation {
      let newItem = Item(context: viewContext)
      newItem.timestamp = Date()

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }

  private func deleteItems(items: [FetchedResults<Item>.Element]) {
    withAnimation {
      items.forEach(viewContext.delete)

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
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

  @State private var archiveExpanded: Bool = false
  @StateObject var contactsContext = ContactsContext()

  var body: some View {
    DisclosureGroup(isExpanded: $archiveExpanded) {
      let groups = contactsContext.contactsMetaData.getGroupsByContainerId(
        containerId: containerId)

      ForEach(ContactsManager.getSearchResults(groups: groups, searchText: searchText)) { group in
        let contacts = contactsContext.contactsMetaData.getContactsByGroupId(
          groupId: group.identifier)
        ContactsNav(
          contacts: contacts, containerId: containerId, groups: groups,
          navigationTitle: "\(group.name) (\(contacts.count))")
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

private struct ContactsNav: View {
  let contacts: [CNContact]
  let containerId: String
  let groups: [CNGroup]
  let navigationTitle: String
  var group: CNGroup?

  @State private var isShowingEditAlert = false
  @State private var isShowingDeleteAlert = false
  @State private var alertInput = ""
  @EnvironmentObject var contactsContext: ContactsContext

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
            print("isShowingDeleteAlert")
          }
          .tint(.red)
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
    NavigationLink {
      ContactsListView(
        navigationTitle: navigationTitle, contacts: contacts, containerId: containerId,
        allGroups: groups)
    } label: {
      Text(navigationTitle)
    }
  }
}

struct Contacts_Previews: PreviewProvider {
  static var previews: some View {
    ContactsView().environment(
      \.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
