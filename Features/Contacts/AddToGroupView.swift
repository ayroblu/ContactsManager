//
//  AddToGroupView.swift
//  ContactsManager
//
//  Created by Ben Lu on 12/09/2022.
//

import Contacts
import SwiftUI

struct AddToGroupView: View {
  let contacts: [Contact]
  let groups: [CNGroup]
  let initialSelectedGroups: [String: SelectSelection]

  @State var newGroups: [String] = []
  @State var selectedGroups: [String: SelectSelection]
  @Binding var isShowing: Bool

  init(
    contacts: [Contact], groups: [CNGroup], initialSelectedGroups: [String: SelectSelection],
    isShowing: Binding<Bool>
  ) {
    self.contacts = contacts
    self.groups = groups
    self.selectedGroups = initialSelectedGroups
    self.initialSelectedGroups = initialSelectedGroups
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
            print("save", getDiffGroups())
            isShowing = false
          }) {
            Text("Save").bold()
          })
    }
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
