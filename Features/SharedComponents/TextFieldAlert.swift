//
//  TextFieldAlert.swift
//  ContactsManager
//
//  Created by Ben Lu on 14/09/2022.
//

import SwiftUI

struct TextFieldAlert<Presenting>: View where Presenting: View {
  @Binding var isShowing: Bool
  @Binding var text: String
  let onSave: () -> Void
  let presenting: Presenting
  let title: String

  var body: some View {
    GeometryReader { (deviceSize: GeometryProxy) in
      ZStack {
        self.presenting
          .disabled(isShowing)
        VStack {
          Text(self.title)
          TextField(self.title, text: self.$text)
          Divider()
          HStack {
            Button(action: {
              withAnimation {
                self.isShowing.toggle()
              }
            }) {
              Text("Dismiss")
            }
            Button(action: {
              withAnimation {
                self.onSave()
                self.isShowing.toggle()
              }
            }) {
              Text("Save")
            }
          }
        }
        .padding()
        .background(.background)
        .frame(
          width: deviceSize.size.width * 0.7,
          height: deviceSize.size.height * 0.7
        )
        .shadow(radius: 1)
        .opacity(self.isShowing ? 1 : 0)
      }
    }
  }
}
extension View {
  func textFieldAlert(
    isShowing: Binding<Bool>, text: Binding<String>, onSave: @escaping () -> Void, title: String
  ) -> some View {
    TextFieldAlert(isShowing: isShowing, text: text, onSave: onSave, presenting: self, title: title)
  }
}

private struct Preview: View {
  @State var isShowing: Bool = true
  @State var text: String = ""

  var body: some View {
    TextFieldAlert(
      isShowing: $isShowing, text: $text, onSave: {}, presenting: self,
      title: "Enter some information here!")
  }
}
struct TextFieldAlert_Previews: PreviewProvider {
  static var previews: some View {
    Preview()
  }
}
