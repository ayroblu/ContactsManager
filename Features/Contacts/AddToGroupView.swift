//
//  AddToGroupView.swift
//  ContactsManager
//
//  Created by Ben Lu on 12/09/2022.
//

import Contacts
import SwiftUI

struct AddToGroupView: View {
  let contacts: [CNContact]
  let containerId: String
  let groups: [CNGroup]
  let initialSelectedGroups: [String: SelectSelection]
  let onSave: () -> Void

  @EnvironmentObject var contactsContext: ContactsContext
  @State var newGroups: [String] = []
  @State var selectedGroups: [String: SelectSelection]
  @Binding var isShowing: Bool

  init(
    contacts: [CNContact], containerId: String, groups: [CNGroup],
    initialSelectedGroups: [String: SelectSelection],
    isShowing: Binding<Bool>, onSave: @escaping () -> Void
  ) {
    self.contacts = contacts
    self.containerId = containerId
    self.groups = groups
    self.selectedGroups = initialSelectedGroups
    self.initialSelectedGroups = initialSelectedGroups
    self.onSave = onSave
    self._isShowing = isShowing
  }

  // Form which shows radio group of list of groups (+ counts) + add a group text input
  var body: some View {
    NavigationView {
      List {
        Section {
          MultiInsertListView(insertLabel: "add group", options: $newGroups)
        } header: {
          Text("New groups")
        }
        Section {
          MultiSelectionListView(
            options: groups, optionToString: { $0.name }, selections: $selectedGroups)
        } header: {
          Text("Existing groups")
        }
      }.listStyle(.grouped)
        .navigationBarTitle(Text("Edit Groups"), displayMode: .inline)
        .navigationBarItems(
          leading: Button(action: {
            isShowing = false
          }) {
            Text("Cancel")
          },
          trailing: Button(action: {
            saveGroups()
          }) {
            Text("Save").bold()
          })
    }
  }

  private func saveGroups() {
    let diffGroups = getDiffGroups()
    for (groupId, sel) in diffGroups {
      do {
        if let group = groups.first(where: { group in group.id == groupId }) {
          switch sel {
          case .Unselected:
            try removeContacts(contacts, from: [group])
          case .Selected:
            try addContacts(contacts, to: [group])
          case .MixedSelected:
            print("This shouldn't happen")
          }
        }
      } catch {
        print(error)
      }
    }

    let newGroupsToAdd = Set(newGroups).filter { $0.count > 0 }
    for groupName in newGroupsToAdd {
      do {
        let group = try addGroup(groupName, toContainerWithIdentifier: containerId)
        try addContacts(contacts, to: [group])
      } catch {
        print(error)
      }
    }

    onSave()
    contactsContext.contactsMetaData = getContactsMetaData()
    isShowing = false
  }

  private func getDiffGroups() -> [String: SelectSelection] {
    groups.reduce([String: SelectSelection]()) {
      (result, nextGroup) -> [String: SelectSelection] in
      var result = result
      if selectedGroups[nextGroup.id] != initialSelectedGroups[nextGroup.id] {
        result[nextGroup.id] = selectedGroups[nextGroup.id]
      }
      return result
    }
  }
}
