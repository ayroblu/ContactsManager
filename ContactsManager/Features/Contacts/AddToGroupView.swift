//
//  AddToGroupView.swift
//  ContactsManager
//
//  Created by Ben Lu on 12/09/2022.
//

import Contacts
import CoreData
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
  @FetchRequest private var cdArchivedGroups: FetchedResults<CDArchivedGroups>

  init(
    contacts: [CNContact], containerId: String, groups: [CNGroup],
    initialSelectedGroups: [String: SelectSelection],
    isShowing: Binding<Bool>, onSave: @escaping () -> Void
  ) {
    _cdArchivedGroups = FetchRequest<CDArchivedGroups>(
      sortDescriptors: [],
      predicate: NSPredicate(
        format: "containerId = %@", containerId
      ))
    self.contacts = contacts
    self.containerId = containerId
    self.groups = groups
    _selectedGroups = State(initialValue: initialSelectedGroups)
    self.initialSelectedGroups = initialSelectedGroups
    self.onSave = onSave
    self._isShowing = isShowing
  }

  // Form which shows radio group of list of groups (+ counts) + add a group text input
  var body: some View {
    let archivedGroupIdsSet = Set(cdArchivedGroups.compactMap { $0.groupId })
    let activeGroups = groups.filter { !archivedGroupIdsSet.contains($0.identifier) }
    let archivedGroups = groups.filter { archivedGroupIdsSet.contains($0.identifier) }
    NavigationView {
      List {
        Section {
          MultiInsertListView(insertLabel: "add group", options: $newGroups)
        } header: {
          Text("New groups")
        }
        Section {
          MultiSelectionListView(
            options: activeGroups, optionToString: { $0.name }, selections: $selectedGroups)
        } header: {
          Text("Existing groups")
        }
        Section {
          MultiSelectionListView(
            options: archivedGroups, optionToString: { $0.name }, selections: $selectedGroups)
        } header: {
          Text("Archived groups")
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
        print("Save groups error", error)
      }
    }

    let newGroupsToAdd = Set(newGroups).filter { $0.count > 0 }
    for groupName in newGroupsToAdd {
      do {
        if let group = try addGroup(groupName, toContainerWithIdentifier: containerId) {
          try addContacts(contacts, to: [group])
        }
      } catch {
        print("new groups error", error)
      }
    }

    onSave()
    contactsContext.refresh()
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
