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
  contactStore.requestAccess(for: CNEntityType.contacts) { _, error in
    // _ -> isGranted
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

func getContactsMetaData2() -> ContactsMetaData2 {
  let keys = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactViewController.descriptorForRequiredKeys(),
  ]

  let contactStore = CNContactStore()
  var contactsMetaData = ContactsMetaData2()
  contactStore.requestAccess(for: CNEntityType.contacts) { _, error in
    // _ -> isGranted
    do {
      let containers = try contactStore.containers(matching: nil)
      contactsMetaData.containerById = Dictionary(
        uniqueKeysWithValues: containers.map { ($0.identifier, $0) })
      try containers.forEach { container in
        let contacts = try contactStore.unifiedContacts(
          matching: CNContact.predicateForContactsInContainer(
            withIdentifier: container.identifier),
          keysToFetch: keys)
        contactsMetaData.contactIdsByContainerId[container.identifier] = contacts.map {
          $0.identifier
        }
        for contact in contacts where contactsMetaData.contactById[contact.identifier] == nil {
          contactsMetaData.contactById[contact.identifier] = contact
        }

        let groups = try contactStore.groups(
          matching: CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier))
        contactsMetaData.groupIdsByContainerId[container.identifier] = groups.map { $0.identifier }

        for group in groups where contactsMetaData.groupById[group.identifier] == nil {
          contactsMetaData.groupById[group.identifier] = group
        }
        for group in groups {
          let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
          let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
          contactsMetaData.contactIdsByGroupId[group.identifier] = contacts.map { $0.identifier }
        }
      }
    } catch let error {
      print("unable to fetch contacts \(error)")
    }
  }
  return contactsMetaData
}

let ContactStore = CNContactStore()

// Add to group, remove from group, add to new groups
func addGroup(_ name: String, toContainerWithIdentifier identifier: String) throws -> CNGroup {
  let request = CNSaveRequest()
  let group = CNMutableGroup()
  group.name = name
  request.add(group, toContainerWithIdentifier: identifier)
  try ContactStore.execute(request)
  return group.copy() as! CNGroup
}
func addContacts(_ contacts: [CNContact], to groups: [CNGroup]) throws {
  let request = CNSaveRequest()
  for contact in contacts {
    for group in groups {
      request.addMember(contact, to: group)
    }
  }
  try ContactStore.execute(request)
}
func removeContacts(_ contacts: [CNContact], from groups: [CNGroup]) throws {
  let request = CNSaveRequest()
  for contact in contacts {
    for group in groups {
      request.removeMember(contact, from: group)
    }
  }
  try ContactStore.execute(request)
}

struct ContactsMetaData {
  var containers: [Container]
  var contactsById: [String: Contact]
  var contacts: [Contact] {
    contactsById.map { $0.value }.sorted()
  }
}
struct ContactsMetaData2 {
  var containerById: [String: CNContainer] = [:]
  var groupById: [String: CNGroup] = [:]
  var contactById: [String: CNContact] = [:]
  var groupIdsByContainerId: [String: [String]] = [:]
  var contactIdsByContainerId: [String: [String]] = [:]
  var contactIdsByGroupId: [String: [String]] = [:]

  var containers: [CNContainer] {
    containerById.map { $0.value }.sorted()
  }
  func groupsByContainerId(containerId: String) -> [CNGroup] {
    let groupIds: [String] = groupIdsByContainerId[containerId] ?? []
    return groupIds.compactMap { groupById[$0] }.sorted()
  }
  func contactsByContainerId(containerId: String) -> [CNContact] {
    let contactIds: [String] = contactIdsByContainerId[containerId] ?? []
    return contactIds.compactMap { contactById[$0] }.sorted()
  }
  func contactsByGroupId(groupId: String) -> [CNContact] {
    let contactIds: [String] = contactIdsByGroupId[groupId] ?? []
    return contactIds.compactMap { contactById[$0] }.sorted()
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
extension CNContainer: Comparable {
  public static func < (lhs: CNContainer, rhs: CNContainer) -> Bool {
    lhs.name < rhs.name
  }
}
extension CNGroup: Comparable {
  public static func < (lhs: CNGroup, rhs: CNGroup) -> Bool {
    lhs.name < rhs.name
  }
}
extension CNContact: Comparable {
  func toMaybeName() -> String? {
    CNContactFormatter.string(from: self, style: .fullName)
  }
  public static func < (lhs: CNContact, rhs: CNContact) -> Bool {
    lhs.toMaybeName() ?? "" < rhs.toMaybeName() ?? ""
  }
}
extension Contact: Comparable {
  static func < (lhs: Contact, rhs: Contact) -> Bool {
    lhs.toMaybeName() ?? "" < rhs.toMaybeName() ?? ""
  }
}
