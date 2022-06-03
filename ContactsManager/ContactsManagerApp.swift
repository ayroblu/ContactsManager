//
//  ContactsManagerApp.swift
//  ContactsManager
//
//  Created by Ben Lu on 03/06/2022.
//

import SwiftUI

@main
struct ContactsManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
