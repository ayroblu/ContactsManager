//
//  ContactsView.swift
//  ContactsManager
//
//  Created by Ben Lu on 04/06/2022.
//

import CoreData
import SwiftUI

struct ContactsView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
    animation: .default)
  private var items: FetchedResults<Item>
  @State private var searchText = ""

  var body: some View {
    NavigationView {
      List {
        ForEach(items) { item in
          DeleteConfirmationView(
            buttonText: "Delete", confirmationText: "Delete Contact",
            action: {
              deleteItems(items: [item])
            }
          ) {
            NavigationLink {
              ContactsDetailView(item: item)
            } label: {
              if let timestamp = item.timestamp {
                Text(timestamp, formatter: itemFormatter)
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
      }
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
