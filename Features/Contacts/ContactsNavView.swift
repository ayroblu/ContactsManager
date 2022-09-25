//
//  ContactsNavView.swift
//  ContactsManager
//
//  Created by Ben Lu on 25/09/2022.
//

import Contacts
import CoreData
import SwiftUI

struct ContactsNavView: View {
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

// struct ContactsNavView_Previews: PreviewProvider {
//     static var previews: some View {
//         ContactsNavView()
//     }
// }
