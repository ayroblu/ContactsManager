//
//  ContactsSync.swift
//  ContactsManager
//
//  Created by Ben Lu on 06/06/2022.
//

import Contacts

func getContactsMetaData() -> ContactsMetaData {
  //  let request = CNContactFetchRequest(keysToFetch: keys)
  let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]

  let contactStore = CNContactStore()
  var contactsMetaData = ContactsMetaData(
    groups: [], containers: [], contactsById: [String: Contact]())
  contactStore.requestAccess(for: CNEntityType.contacts) { isGranted, error in
    //    contactsMetaData.contacts.append(Contact())
    print("isGranted", isGranted, "; error", error as Any)
    do {
      let groups = try contactStore.groups(matching: nil)
      print(groups.map { c in c.name })
      let containers = try contactStore.containers(matching: nil)
      print("containers", containers)
      contactsMetaData.containers = containers
      contactsMetaData.groups = groups
      try containers.forEach { container in
        let contacts = try contactStore.unifiedContacts(
          matching: CNContact.predicateForContactsInContainer(withIdentifier: container.identifier),
          keysToFetch: keys)
        contacts.forEach { contact in
          if var contact = contactsMetaData.contactsById[contact.identifier] {
            contact.containers.append(container)
          } else {
            contactsMetaData.contactsById[contact.identifier] = Contact(
              contactData: contact, groups: [], containers: [container])
          }
        }
      }
      //      var contacts: [CNContact] = []
      //      try contactStore.enumerateContacts(with: request) {
      //        (contact, stop) in
      //        // Array containing all unified contacts from everywhere
      //        contacts.append(contact)
      //      }
      //      print(
      //        "contacts",
      //        contacts.map { c in CNContactFormatter.string(from: c, style: .fullName) })

      try groups.forEach { group in
        let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
        let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
        contacts.forEach { contact in
          if var contact = contactsMetaData.contactsById[contact.identifier] {
            contact.groups.append(group)
          }
        }
      }
    } catch let error {
      print("unable to fetch contacts \(error)")
    }
  }
  return contactsMetaData
}

struct ContactsMetaData {
  var groups: [CNGroup]
  var containers: [CNContainer]
  var contactsById: [String: Contact]
  var contacts: [Contact] {
    contactsById.map { $0.value }.sort(by: (a, b) -> a > b)
  }
}

struct Contact: Identifiable {
  var id: String { contactData.identifier }
  var contactData: CNContact
  var groups: [CNGroup]
  var containers: [CNContainer]
}
