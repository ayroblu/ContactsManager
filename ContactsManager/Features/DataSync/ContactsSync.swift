//
//  ContactsSync.swift
//  ContactsManager
//
//  Created by Ben Lu on 06/06/2022.
//

import Contacts
import ContactsUI

let keys = [
  CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
  CNContactViewController.descriptorForRequiredKeys(),
]

func getContactsMetaData() -> ContactsMetaData {
  let (result, time) = timeFunc(myFunc: getContactsMetaDataRaw)
  print("getContactsMetaData: \(time) milliseconds")
  return result
}
func timeFunc<T>(myFunc: () -> T) -> (T, Double) {
  let start = DispatchTime.now()
  let result = myFunc()
  let end = DispatchTime.now()

  let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
  let timeInterval = Double(nanoTime) / 1_000_000

  return (result, timeInterval)
}
private func getContactsMetaDataRaw() -> ContactsMetaData {
  let contactStore = CNContactStore()
  var contactsMetaData = ContactsMetaData()
  do {
    // Don't use unified contacts for everything:
    // https://stackoverflow.com/questions/52670973/cant-add-unified-cncontact-to-cngroup-in-ios
    let containers = try contactStore.containers(matching: nil)
    contactsMetaData.containerById = Dictionary(
      uniqueKeysWithValues: containers.map { ($0.identifier, $0) })
    try containers.forEach { container in
      let predicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
      let contacts = try fetchContacts(predicate: predicate)
      contactsMetaData.contactIdsByContainerId[container.identifier] = contacts.map {
        $0.identifier
      }
      // for contact in contacts where contactsMetaData.contactById[contact.identifier] == nil {
      //   contactsMetaData.contactById[contact.identifier] = contact
      // }
      for contact in contacts {
        if contactsMetaData.contactByContainerIdById[container.identifier] == nil {
          contactsMetaData.contactByContainerIdById[container.identifier] = [contact.identifier: contact]
        } else {
          contactsMetaData.contactByContainerIdById[container.identifier]![contact.identifier] = contact
        }
      }

      let groups = try contactStore.groups(
        matching: CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier))
      contactsMetaData.groupIdsByContainerId[container.identifier] = groups.map { $0.identifier }

      for group in groups where contactsMetaData.groupById[group.identifier] == nil {
        contactsMetaData.groupById[group.identifier] = group
      }
      for group in groups {
        let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
        let contacts = try fetchContacts(predicate: predicate)
        contactsMetaData.contactIdsByGroupId[group.identifier] = contacts.map { $0.identifier }
        for contact in contacts {
          if var groupIds = contactsMetaData.groupIdsByContactId[contact.identifier] {
            groupIds.insert(group.identifier)
          } else {
            contactsMetaData.groupIdsByContactId[contact.identifier] = [group.identifier]
          }
        }
      }
      contactsMetaData.ungroupedContactIdsByContainerId[container.identifier] = contacts.filter {
        (contactsMetaData.groupIdsByContactId[$0.identifier] ?? Set()).count == 0
      }.map { $0.identifier }
    }
  } catch let error {
    print("unable to fetch contacts \(error)")
  }
  return contactsMetaData
}

let ContactStore = CNContactStore()

func fetchContacts(predicate: NSPredicate) throws -> [CNContact] {
  // Formerly
  // let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
  // But we don't use unified contacts cause they're shared across containers
  var contacts = [CNContact]()
  let request = CNContactFetchRequest(keysToFetch: keys)
  request.unifyResults = false
  request.predicate = predicate
  try ContactStore.enumerateContacts(with: request) {(contact, _) in
    // _ => stop
    contacts.append(contact)
  }
  return contacts
}

func addGroup(_ name: String, toContainerWithIdentifier identifier: String) throws -> CNGroup? {
  let request = CNSaveRequest()
  let group = CNMutableGroup()
  group.name = name
  request.add(group, toContainerWithIdentifier: identifier)
  try ContactStore.execute(request)
  // return group.copy() as! CNGroup
  guard let resultGroup = group.copy() as? CNGroup else { return nil }
  return resultGroup
}
func editGroupName(group: CNGroup, name: String) throws {
  guard let mutableGroup = group.mutableCopy() as? CNMutableGroup else { return }
  let request = CNSaveRequest()
  mutableGroup.name = name
  request.update(mutableGroup)
  try ContactStore.execute(request)
}
func editGroupNameSafe(group: CNGroup, name: String) {
  do {
    try editGroupName(group: group, name: name)
  } catch let error {
    print("unable to editGroupName \(error)")
  }
}
func deleteGroup(group: CNGroup) throws {
  guard let mutableGroup = group.mutableCopy() as? CNMutableGroup else { return }
  let request = CNSaveRequest()
  request.delete(mutableGroup)
  try ContactStore.execute(request)
}
func deleteGroupSafe(group: CNGroup) {
  do {
    try deleteGroup(group: group)
  } catch let error {
    print("unable to deleteGroup \(error)")
  }
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
  var containerById: [String: CNContainer] = [:]
  var groupById: [String: CNGroup] = [:]
  // var contactById: [String: CNContact] = [:]
  var contactByContainerIdById: [String: [String: CNContact]] = [:]
  var groupIdsByContainerId: [String: [String]] = [:]
  var contactIdsByContainerId: [String: [String]] = [:]
  var contactIdsByGroupId: [String: [String]] = [:]
  var groupIdsByContactId: [String: Set<String>] = [:]
  // Maybe - tbd if this is needed
  // var containerIdsByContactId: [String: [String]] = [:]
  var ungroupedContactIdsByContainerId: [String: [String]] = [:]

  var containers: [CNContainer] {
    containerById.map { $0.value }.sorted()
  }
  func getGroupsByContainerId(containerId: String) -> [CNGroup] {
    let groupIds: [String] = groupIdsByContainerId[containerId] ?? []
    return groupIds.compactMap { groupById[$0] }.sorted()
  }
  func getContactsByContainerId(containerId: String) -> [CNContact] {
    let contactIds: [String] = contactIdsByContainerId[containerId] ?? []
    // return contactIds.compactMap { contactById[$0] }.sorted()
    return contactIds.compactMap { contactByContainerIdById[containerId]?[$0] }.sorted()
  }
  // func getContactsByGroupId(groupId: String) -> [CNContact] {
  func getContactsByGroupId(containerId: String, groupId: String) -> [CNContact] {
    let contactIds: [String] = contactIdsByGroupId[groupId] ?? []
    // return contactIds.compactMap { contactById[$0] }.sorted()
    return contactIds.compactMap { contactByContainerIdById[containerId]?[$0] }.sorted()
  }
  func getUngroupedContactsByContainerId(containerId: String) -> [CNContact] {
    let contactIds: [String] = ungroupedContactIdsByContainerId[containerId] ?? []
    // return contactIds.compactMap { contactById[$0] }.sorted()
    return contactIds.compactMap { contactByContainerIdById[containerId]?[$0] }.sorted()
  }
}

extension CNContainer: Identifiable {
  public var id: String { identifier }
}
extension CNContainer: Comparable {
  public static func < (lhs: CNContainer, rhs: CNContainer) -> Bool {
    lhs.name < rhs.name
  }
}

extension CNGroup: Identifiable {
  public var id: String { identifier }
}
extension CNGroup: Comparable {
  public static func < (lhs: CNGroup, rhs: CNGroup) -> Bool {
    lhs.name < rhs.name
  }
}

extension CNContact: Identifiable {
  public var id: String { identifier }
}
extension CNContact: Comparable {
  func toMaybeName() -> String? {
    CNContactFormatter.string(from: self, style: .fullName)
  }
  public static func < (lhs: CNContact, rhs: CNContact) -> Bool {
    lhs.toMaybeName() ?? "" < rhs.toMaybeName() ?? ""
  }
}
extension CNContact {
  public override var hash: Int {
    var hasher = Hasher()
    // Identifiers
    hasher.combine(identifier)
    hasher.combine(contactType)
    // Name info
    hasher.combine(namePrefix)
    hasher.combine(givenName)
    hasher.combine(middleName)
    hasher.combine(familyName)
    hasher.combine(previousFamilyName)
    hasher.combine(nameSuffix)
    hasher.combine(nickname)
    hasher.combine(phoneticGivenName)
    hasher.combine(phoneticMiddleName)
    hasher.combine(phoneticFamilyName)
    // work info
    hasher.combine(jobTitle)
    hasher.combine(departmentName)
    hasher.combine(organizationName)
    hasher.combine(phoneticOrganizationName)
    // addresses
    hasher.combine(postalAddresses)
    hasher.combine(emailAddresses)
    hasher.combine(urlAddresses)
    // phone numbers
    hasher.combine(phoneNumbers)
    // social profiles
    hasher.combine(socialProfiles)
    // birthdays
    hasher.combine(birthday)
    hasher.combine(nonGregorianBirthday)
    hasher.combine(dates)
    // // notes (requires extra permissions)
    // hasher.combine(note)
    // contact images
    hasher.combine(imageData)
    hasher.combine(thumbnailImageData)
    hasher.combine(imageDataAvailable)
    // related information
    hasher.combine(contactRelations)
    hasher.combine(instantMessageAddresses)
    return hasher.finalize()
  }
}
