//
//  ContactsSync.swift
//  ContactsManager
//
//  Created by Ben Lu on 06/06/2022.
//

import Contacts
import ContactsUI

func getContactsMetaData() -> ContactsMetaData {
  //  let request = CNContactFetchRequest(keysToFetch: keys)
  let keys = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactViewController.descriptorForRequiredKeys(),
  ]

  let contactStore = CNContactStore()
  var contactsMetaData = ContactsMetaData(containers: [], contactsById: [String: Contact]())
  contactStore.requestAccess(for: CNEntityType.contacts) { isGranted, error in
    do {
      let containers = try contactStore.containers(matching: nil)
      contactsMetaData.containers = try containers.map { container in
        let groups = try contactStore.groups(
          matching: CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier))
        return Container(groups: groups, container: container)
      }
      try contactsMetaData.containers.forEach { container in
        let contacts = try contactStore.unifiedContacts(
          matching: CNContact.predicateForContactsInContainer(
            withIdentifier: container.container.identifier),
          keysToFetch: keys)
        contacts.forEach { contact in
          if var contact = contactsMetaData.contactsById[contact.identifier] {
            contact.containers.append(container)
          } else {
            contactsMetaData.contactsById[contact.identifier] = Contact(
              contactData: contact, groups: [], containers: [container])
          }
        }
        try container.groups.forEach { group in
          let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
          let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
          contacts.forEach { contact in
            contactsMetaData.contactsById[contact.identifier]?.groups.append(group)
          }
        }
      }
    } catch let error {
      print("unable to fetch contacts \(error)")
    }
  }
  return contactsMetaData
}
let ContactStore = CNContactStore()

func addGroup(_ name: String, toContainerWithIdentifier identifier: String? = nil) throws {
  let request = CNSaveRequest()
  let group = CNMutableGroup()
  group.name = name
  request.add(group, toContainerWithIdentifier: identifier)
  try ContactStore.execute(request)
}

struct ContactsMetaData {
  var containers: [Container]
  var contactsById: [String: Contact]
  var contacts: [Contact] {
    contactsById.map { $0.value }.sorted()
  }
}

struct Contact {
  var contactData: CNContact
  var groups: [CNGroup]
  var containers: [Container]

  func toMaybeName() -> String? {
    CNContactFormatter.string(from: contactData, style: .fullName)
  }
}
extension Contact: Identifiable {
  var id: String { contactData.identifier }
}
extension Contact: Hashable {
}

struct Container: Hashable {
  var groups: [CNGroup]
  var container: CNContainer
}
extension Container: Identifiable {
  public var id: String { container.identifier }
}
extension CNGroup: Identifiable {
  public var id: String { identifier }
}
extension CNContainer: Identifiable {
  public var id: String { identifier }
}
extension Contact: Comparable {
  static func < (lhs: Contact, rhs: Contact) -> Bool {
    lhs.toMaybeName() ?? "" < rhs.toMaybeName() ?? ""
  }
}
