//
//  ContactsPermissionsView.swift
//  ContactsManager
//
//  Created by Ben Lu on 25/09/2022.
//

import Contacts
import SwiftUI

struct ContactsPermissionsView: View {
  @State private var updaterId = 0

  var body: some View {
    switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
    case CNAuthorizationStatus.notDetermined:
      ToBeDeterminedView(updaterId: $updaterId)
        .id(updaterId)
    case CNAuthorizationStatus.authorized:
      HasPermissionView()
    case CNAuthorizationStatus.restricted:
      Text("Sorry, it appears that your user is restricted, such as due to parental controls")
    case CNAuthorizationStatus.denied:
      DeniedView()
    default:
      Text("This app does not have permissions to view your contacts")
    }
  }
}

private let entryMessage = """
  Thank you for supporting me and downloading ContactsManager!

  You will need to grant access to your contacts for this app to work

  _Your contacts data is never sent to anyone and stays on device!_
  """.trimmingCharacters(in: .whitespacesAndNewlines)

/// This is generally the first view that users will see
private struct ToBeDeterminedView: View {
  @Binding var updaterId: Int

  var body: some View {
    VStack {
      Text("Welcome!").font(.title)
        .padding()
      Text(
        """
        Thank you for supporting me and downloading ContactsManager!

        You will need to grant access to your contacts for this app to work

        _Your contacts data is never sent to anyone and stays on device!_
        """
      )
      Button("Show contacts permission") {
        requestPermission()
      }
      .buttonStyle(.borderedProminent)
    }.padding()
  }

  private func requestPermission() {
    let contactStore = CNContactStore()
    contactStore.requestAccess(for: CNEntityType.contacts) { _, _ in
      updaterId += 1
    }
  }
}

private struct HasPermissionView: View {
  var oldView: some View {
    TabView {
      ContactsView()
        .tabItem {
          Image(systemName: "person.crop.circle")
          Text("Contacts")
        }
      SettingsView()
        .tabItem {
          Image(systemName: "gear.circle")
          Text("Settings")
        }
    }
  }

  var body: some View {
    ContactsView()
      .tabItem {
        Image(systemName: "person.crop.circle")
        Text("Contacts")
      }
  }
}

private struct DeniedView: View {
  // From: https://stackoverflow.com/questions/28152526/how-do-i-open-phone-settings-when-a-button-is-clicked
  let settingsUrl = URL(string: UIApplication.openSettingsURLString)

  var body: some View {
    VStack {
      Text("Please grant permissions to this app for your contacts in your settings")
      if let settingsUrl = settingsUrl, UIApplication.shared.canOpenURL(settingsUrl) {
        Button("Open Settings") {
          UIApplication.shared.open(
            settingsUrl,
            completionHandler: { (success) in
              print("Settings opened: \(success)")  // Prints true
            })
        }
        .buttonStyle(.borderedProminent)
      }
    }.padding()
  }
}

struct ContactsPermissionsView_Previews: PreviewProvider {
  static var previews: some View {
    ContactsPermissionsView()
  }
}
