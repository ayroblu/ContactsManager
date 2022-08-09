//
//  ContactsDetailView.swift
//  ContactsManager
//
//  Created by Ben Lu on 04/06/2022.
//

import Contacts
import SwiftUI

struct ContactsDetailView: View {
  let item: Contact
  var body: some View {
    Text(CNContactFormatter.string(from: item.contactData, style: .fullName) ?? item.id)
  }
}
