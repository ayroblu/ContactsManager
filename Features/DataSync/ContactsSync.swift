//
//  ContactsSync.swift
//  ContactsManager
//
//  Created by Ben Lu on 06/06/2022.
//

import Contacts
import Foundation

func doSync() {
  var contacts: [CNContact] = []
  let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
  let request = CNContactFetchRequest(keysToFetch: keys)

  let contactStore = CNContactStore()
  contactStore.requestAccess(for: CNEntityType.contacts) { _, _ in
    do {
      let groups = try contactStore.groups(matching: NSPredicate(value: true))
      print(groups)
      let containers = try contactStore.containers(matching: NSPredicate(value: true))
      let containerContacts = try containers.map { container in
        try contactStore.unifiedContacts(
          matching: CNContact.predicateForContactsInContainer(withIdentifier: container.identifier),
          keysToFetch: keys)
      }

      try contactStore.enumerateContacts(with: request) {
        (contact, stop) in
        // Array containing all unified contacts from everywhere
        contacts.append(contact)
      }
    } catch let error {
      print("unable to fetch contacts \(error)")
    }
  }
}

struct ContactMetaData {
  let groups: [CNGroup]
  let containers: [CNContainer]
  let contacts: [Contact]
}

struct Contact {
  let data: CNContact
  let groups: [CNGroup]
  let container: CNContainer
}
