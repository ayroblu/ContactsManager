//
//  ContactsListView.swift
//  ContactsManager
//
//  Created by Ben Lu on 11/09/2022.
//

import Contacts
import SwiftUI

struct ContactsListView: View {
  let navigationTitle: String
  let contacts: [CNContact]
  let container: CNContainer
  let allGroups: [CNGroup]

  @Environment(\.editMode) private var editMode
  @EnvironmentObject var contactsContext: ContactsContext
  @State private var searchText = ""
  @State private var selectedContactIds: Set<String> = []
  @State private var isShowingAddToGroupSheet: Bool = false
  @State private var isShowingContactSheet: Bool = false

  var body: some View {
    List(searchResults, selection: $selectedContactIds) { contact in
      if let contactName = CNContactFormatter.string(
        from: contact, style: .fullName)
      {
        NavigationLink(destination: SwiftCNContactViewController(contact: contact)) {
          Text(contactName)
        }
        // Not quite showing recycling sheet in the right way
        //        Button(contactName) { isShowingContactSheet.toggle() }
        //          .sheet(isPresented: $isShowingContactSheet) {
        //            SwiftCNContactViewController(contact: contact.contactData)
        //          }
        //          .buttonStyle(ListButtonStyle())
      } else {
        Text("deleting")
      }
    }
    .navigationTitle(navigationTitle)
    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        if selectedContactIds.count > 0 && editMode?.wrappedValue == .active {
          getAddToGroupButton()
        }
        EditButton()
      }
    }
  }

  private func getAddToGroupButton() -> some View {
    Button(action: { isShowingAddToGroupSheet.toggle() }) {
      Label("Add to Group", systemImage: "plus.square.on.square")
    }
    .sheet(isPresented: $isShowingAddToGroupSheet) {
      let contacts = Array(
        selectedContactIds.compactMap { contactsContext.contactsMetaData.contactById[$0] })
      let selectedGroups = allGroups.reduce([String: SelectSelection]()) {
        (result, nextGroup) -> [String: SelectSelection] in
        var result = result
        result[nextGroup.id] = getSelectSelection(
          fromList: contacts,
          getSet: { from in
            contactsContext.contactsMetaData.groupIdsByContactId[from.identifier] ?? Set()
          }, with: nextGroup.id)
        return result
      }
      AddToGroupView(
        contacts: Array(
          selectedContactIds.compactMap { contactsContext.contactsMetaData.contactById[$0] }),
        container: container,
        groups: allGroups, initialSelectedGroups: selectedGroups,
        isShowing: $isShowingAddToGroupSheet,
        onSave: {
          selectedContactIds = []
          editMode?.wrappedValue = .inactive
        }
      )
    }
  }

  /**
   * Algorithm for picking whether something is in all, none or some of a group, using a lookup dict
   * Basically over 2+ items, if they have different membership, then return mixed, otherwise, need to go through the whole list to be sure
   * Should be faster than allSatisfy + contains (for the mixed case especially)
   */
  private func getSelectSelection<From>(
    fromList: [From], getSet: (From) -> Set<String>, with: String
  ) -> SelectSelection {
    var selectSelection: SelectSelection?
    for from in fromList {
      if getSet(from).contains(with) {
        if selectSelection == SelectSelection.Unselected {
          return SelectSelection.MixedSelected
        } else if selectSelection == nil {
          selectSelection = SelectSelection.Selected
        }
      } else {
        if selectSelection == SelectSelection.Selected {
          return SelectSelection.MixedSelected
        } else if selectSelection == nil {
          selectSelection = SelectSelection.Unselected
        }
      }
    }
    return selectSelection ?? SelectSelection.Unselected
  }

  var searchResults: [CNContact] {
    if searchText.isEmpty {
      return contacts
    } else {
      let lowercasedSearchText = searchText.lowercased()
      return contacts.filter { contact in
        let contactName =
          CNContactFormatter.string(from: contact, style: .fullName) ?? ""
        return contactName.lowercased().contains(lowercasedSearchText)
      }
    }
  }
}

struct ContactsListView_Previews: PreviewProvider {
  static var previews: some View {
    ContactsListView(
      navigationTitle: "Preview", contacts: [], container: CNContainer(), allGroups: []
    )
    .environmentObject(
      ContactsContext(contactsMetaData: ContactsMetaData()))
  }
}
