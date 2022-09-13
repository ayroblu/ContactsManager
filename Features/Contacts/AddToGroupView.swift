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

  @State var newGroups: [String] = []
  @State var selectedGroups: Set<CNGroup> = []
  @Binding var isShowing: Bool

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
            options: groups, optionToString: { $0.name }, selected: $selectedGroups)
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
            print("save", newGroups, selectedGroups)
            isShowing = false
          }) {
            Text("Save").bold()
          })
    }
  }
}
