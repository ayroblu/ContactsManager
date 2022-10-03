//
//  en.swift
//  LocalizationHelper
//
//  Created by Ben Lu on 26/09/2022.
//

import Foundation

let enBase: Set<String> = [
  "Add to Group",
  "All (%lld)",
  "All",
  "Archive",
  "Cancel",
  "Confirm",
  "Contacts",
  "Delete group “%@”?",
  "Delete",
  "Edit Group Name",
  "Edit Groups",
  "Edit",
  "Existing groups",
  "Group name...",
  "Groups",
  "New groups",
  "Not grouped (%lld)",
  "Not grouped",
  "Open Settings",
  "Please grant permissions to this app for your contacts in your settings",
  "Recents (%lld)",
  "Recents",
  "Save",
  "Show contacts permission",
  "Sorry, it appears that your user is restricted, such as due to parental controls",
  "This app does not have permissions to view your contacts",
  "Unarchive",
  "Welcome!",
  "What would you like to call your Contact Group?",
  "add group",

  // Long strings (can't be sorted)
  """
  Thank you for supporting me and downloading Contact Groups Manager!

  You will need to grant access to your contacts for this app to work

  _Your contacts data is never sent to anyone and stays on device!_
  """,

  // Shared components
  "Dismiss",
  "Submit",

  // More temporary strings
  "Select a Group",
  "deleting...",

  // Not used
  "Settings",
  "Sync",
]

let en = Dictionary(uniqueKeysWithValues: enBase.map { ($0, $0) })
let enGB = en

let enBaseInfo: Set<String> = ["NSContactsUsageDescription"]

let enInfo = [
  "NSContactsUsageDescription":
    "This is necessary to fetch and update your contacts and contact groups"
]
let enGBInfo = enInfo
