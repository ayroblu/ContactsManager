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
  let contactsMetaData: ContactsMetaData = getContactsMetaData()

  var body: some View {
    getVariation2()
  }

  private func getNavigationLinksForContacts(
    contacts: [Contact], container: Container, navigationTitle: String
  )
    -> some View
  {
    NavigationLink {
      ContactsListView(
        navigationTitle: navigationTitle, contacts: contacts, allGroups: container.groups,
        contactsMetaData: contactsMetaData)
    } label: {
      Text(navigationTitle)
    }
    .swipeActions(edge: .leading) {
      Button("Edit Tags") {
        print("hi")
      }
    }
  }
  private func getSection(container: Container) -> some View {
    Section {
      let ungroupedContacts = contactsMetaData.contacts.filter {
        return $0.containers.contains(where: { $0.id == container.id })
          && $0.groups.count == 0
      }
      if ungroupedContacts.count > 0 {
        getNavigationLinksForContacts(
          contacts: ungroupedContacts,
          container: container,
          navigationTitle:
            "Not grouped (\(ungroupedContacts.count))")
      }

      let contacts = contactsMetaData.contacts.filter {
        return $0.containers.contains(where: { $0.id == container.id })
      }
      getNavigationLinksForContacts(
        contacts: contacts,
        container: container,
        navigationTitle: "All (\(contacts.count))")

      ForEach(container.groups) { group in
        let contacts = contactsMetaData.contacts.filter {
          // if $0.groups.count > 1 { print("contact groups", $0.groups) }
          return $0.groups.contains(where: { $0.identifier == group.identifier })
        }
        getNavigationLinksForContacts(
          contacts: contacts, container: container,
          navigationTitle: "\(group.name) (\(contacts.count))")
      }
    } header: {
      Text(container.container.name)
    }
  }
  private func getVariation2() -> some View {
    NavigationView {
      List {
        ForEach(contactsMetaData.containers) { container in
          getSection(container: container)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Contacts")
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      Text("Select a Contact")
    }
    // https://stackoverflow.com/questions/65316497/swiftui-navigationview-navigationbartitle-layoutconstraints-issue
    // .navigationViewStyle(StackNavigationViewStyle())
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
}

struct Contacts_Previews: PreviewProvider {
  static var previews: some View {
    ContactsView().environment(
      \.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
