//
//  ContactsContext.swift
//  ContactsManager
//
//  Created by Ben Lu on 13/09/2022.
//

import SwiftUI

class ContactsContext: ObservableObject {
  @Published var contactsMetaData: ContactsMetaData
  let getData: () -> ContactsMetaData

  init(getData: @escaping () -> ContactsMetaData = getContactsMetaData) {
    self.getData = getData
    self.contactsMetaData = getData()
  }
  public func refresh() {
    self.contactsMetaData = getData()
  }
}
