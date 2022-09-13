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
  let contactsMetaData: ContactsMetaData

  @State private var searchText = ""
  @State private var selectedContactIds: Set<String> = []
  @State private var isShowingAddToGroupSheet: Bool = false
  @State private var isShowingContactSheet: Bool = false

  var body: some View {
    List(searchResults, selection: $selectedContactIds) { contact in
      if let contactName = CNContactFormatter.string(
        from: contact.contactData, style: .fullName)
      {
        NavigationLink(destination: SwiftCNContactViewController(contact: contact.contactData)) {
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
        if selectedContactIds.count > 0 {
          Button(action: { isShowingAddToGroupSheet.toggle() }) {
            Label("Add to Group", systemImage: "plus.square.on.square")
          }
          .sheet(isPresented: $isShowingAddToGroupSheet) {
            AddToGroupView(
              contacts: Array(selectedContactIds.compactMap { contactsMetaData.contactsById[$0] }),
              groups: allGroups,
              isShowing: $isShowingAddToGroupSheet)
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
    ContactsListView(
      navigationTitle: "Preview", contacts: [], allGroups: [],
      contactsMetaData: ContactsMetaData(containers: [], contactsById: [:]))
  }
}