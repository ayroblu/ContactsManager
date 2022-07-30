//
//  ContentView.swift
//  ContactsManager
//
//  Created by Ben Lu on 03/06/2022.
//

import CoreData
import SwiftUI

struct ContentView: View {
  var body: some View {
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
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(
      \.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
