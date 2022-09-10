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
    do {
      let groups = try contactStore.groups(matching: nil)
      let containers = try contactStore.containers(matching: nil)
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
      try groups.forEach { group in
        let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
        let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
        contacts.forEach { contact in
          contactsMetaData.contactsById[contact.identifier]?.groups.append(group)
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
    contactsById.map { $0.value }.sorted()
  }
}

struct Contact {
  var contactData: CNContact
  var groups: [CNGroup]
  var containers: [CNContainer]

  func toMaybeName() -> String? {
    CNContactFormatter.string(from: contactData, style: .fullName)
  }
}
extension Contact: Identifiable {
  var id: String { contactData.identifier }
}
extension CNGroup: Identifiable {
  public var id: String { identifier }
}
extension Contact: Comparable {
  static func < (lhs: Contact, rhs: Contact) -> Bool {
    lhs.toMaybeName() ?? "" < rhs.toMaybeName() ?? ""
  }
}
