//
//  ContactsContext.swift
//  ContactsManager
//
//  Created by Ben Lu on 13/09/2022.
//

import SwiftUI

class ContactsContext: ObservableObject {
  @Published var contactsMetaData: ContactsMetaData

  init(contactsMetaData: ContactsMetaData = getContactsMetaData()) {
    self.contactsMetaData = contactsMetaData
  }
}
