//
//  ContentView.swift
//  ContactsManager
//
//  Created by Ben Lu on 03/06/2022.
//

import CoreData
import SwiftUI

struct ContentView: View {
  let disabled: Void = disableLayoutConstraintLog()

  var body: some View {
    ContactsPermissionsView()
  }
}

/// https://stackoverflow.com/questions/65316497/swiftui-navigationview-navigationbartitle-layoutconstraints-issue
private func disableLayoutConstraintLog() {
  UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(
      \.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
