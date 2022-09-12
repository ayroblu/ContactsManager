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

  private func getNavigationLinksForContacts(contacts: [Contact], navigationTitle: String)
    -> some View
  {
    NavigationLink {
      ContactsListView(
        navigationTitle: navigationTitle, contacts: contacts, allGroups: contactsMetaData.groups)
    } label: {
      Text(navigationTitle)
    }
    .swipeActions(edge: .leading) {
      Button("Edit Tags") {
        print("hi")
      }
    }
  }
  private func getVariation2() -> some View {
    NavigationView {
      List {
        let ungroupedContacts = contactsMetaData.contacts.filter {
          return $0.groups.count == 0
        }
        if ungroupedContacts.count > 0 {
          Section {
            getNavigationLinksForContacts(
              contacts: ungroupedContacts,
              navigationTitle: "Not Grouped (\(ungroupedContacts.count))")
          } header: {
            Text("Auto groups")
          }
        }
        Section {
          ForEach(contactsMetaData.groups) { group in
            let contacts = contactsMetaData.contacts.filter {
              // if $0.groups.count > 1 { print("contact groups", $0.groups) }
              return $0.groups.contains(where: { $0.identifier == group.identifier })
            }
            getNavigationLinksForContacts(
              contacts: contacts, navigationTitle: "\(group.name) (\(contacts.count))")
          }
        } header: {
          Text("Groups")
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

  private func getVariation1() -> some View {
    NavigationView {
      List {
        ForEach(contactsMetaData.groups) { group in
          let contacts = contactsMetaData.contacts.filter {
            if $0.groups.count > 1 { print("contact groups", $0.groups) }
            return $0.groups.contains(where: { $0.identifier == group.identifier })
          }
          Section {
            ForEach(contacts) { contact in
              DeleteConfirmationView(
                buttonText: "Delete", confirmationText: "Delete Contact",
                action: {
                  // deleteItems(items: [contact])
                }
              ) {
                NavigationLink {
                  ContactsDetailView(item: contact)
                } label: {
                  if let contactName = CNContactFormatter.string(
                    from: contact.contactData, style: .fullName)
                  {
                    Text(contactName)
                  } else {
                    Text("deleting")
                  }
                }
                .swipeActions(edge: .leading) {
                  Button("Edit Tags") {
                    print("hi")
                  }
                }
              }
            }
          } header: {
            Text("\(group.name) (\(contacts.count))")
          }
        }
      }
      .listStyle(.sidebar)
      .navigationTitle("Contacts")
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
      .toolbar {
        //                ToolbarItem(placement: .navigationBarTrailing) {
        //                    EditButton()
        //                }
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      Text("Select a Contact")
    }
    // https://stackoverflow.com/questions/65316497/swiftui-navigationview-navigationbartitle-layoutconstraints-issue
    .navigationViewStyle(StackNavigationViewStyle())
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
