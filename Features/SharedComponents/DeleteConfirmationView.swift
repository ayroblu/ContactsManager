//
//  DeleteConfirmationView.swift
//  ContactsManager
//
//  Created by Ben Lu on 05/06/2022.
//

import SwiftUI

struct DeleteConfirmationView<ItemView>: View where ItemView: View {
    let buttonText: String
    let confirmationText: String
    let action: () -> Void
    let content: () -> ItemView
    
    @State private var isShowingConfirmationDialog = false

//    init(buttonText: String, confirmationText: String, action: () -> Void, content: () -> ItemView) {
//        self.buttonText = buttonText
//        self.confirmationText = confirmationText
//        self.action = action
//        self.content = content
//    }

    var body: some View {
        content()
            .swipeActions {
                Button(buttonText, role: .destructive) {
                    isShowingConfirmationDialog = true
                }
            }
            .confirmationDialog(confirmationText, isPresented: $isShowingConfirmationDialog) {
                Button(confirmationText, role: .destructive) {
                    isShowingConfirmationDialog = false
                    action()
                }
            }
    }
}

struct ConfirmationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteConfirmationView(buttonText: "Delete", confirmationText: "Delete Contact", action: {
            print("delete")
        }) {
            Text("Some text")
                .swipeActions(edge: .leading) {
                    Button("Edit Tags") {
                        print("hi")
                    }
                }
        }
    }
}
