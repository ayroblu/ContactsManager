//
//  SettingsView.swift
//  ContactsManager
//
//  Created by Ben Lu on 05/06/2022.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sync")) {
                    Toggle(isOn: .constant(true), label: {Text("Sync")})
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
