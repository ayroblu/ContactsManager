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
  let contacts: [Contact]
  let allGroups: [CNGroup]
  @State private var searchText = ""
  @State private var selectedContactIds: Set<String> = []
  @State private var isShowingAddToGroupSheet: Bool = false

  var body: some View {
    List(searchResults, selection: $selectedContactIds) { contact in
      if let contactName = CNContactFormatter.string(
        from: contact.contactData, style: .fullName)
      {
        Text(contactName)
      } else {
        Text("deleting")
      }
    }
    .navigationTitle(navigationTitle)
    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        if selectedContactIds.count > 0 {
          Button(action: { isShowingAddToGroupSheet.toggle() }) {
            Label("Add to Group", systemImage: "plus.square.on.square")
          }
          .sheet(isPresented: $isShowingAddToGroupSheet) {
            AddToGroupView(groups: allGroups, isShowing: $isShowingAddToGroupSheet)
          }
        }
        EditButton()
      }
    }
  }

  var searchResults: [Contact] {
    if searchText.isEmpty {
      return contacts
    } else {
      let lowercasedSearchText = searchText.lowercased()
      return contacts.filter { contact in
        let contactName =
          CNContactFormatter.string(from: contact.contactData, style: .fullName) ?? ""
        return contactName.lowercased().contains(lowercasedSearchText)
      }
    }
  }
}

struct ContactsListView_Previews: PreviewProvider {
  static var previews: some View {
    ContactsListView(navigationTitle: "Preview", contacts: [], allGroups: [])
  }
}
