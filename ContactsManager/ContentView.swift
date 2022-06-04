//
//  ContentView.swift
//  ContactsManager
//
//  Created by Ben Lu on 03/06/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        Contacts()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
