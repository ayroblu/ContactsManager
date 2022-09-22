//
//  TextFieldAlert.swift
//  ContactsManager
//
//  Created by Ben Lu on 14/09/2022.
//

import SwiftUI

typealias TextFieldAlert = SwiftUIAlertInputViewController

extension View {
  func textFieldAlert(
    isShowing: Bool,
    content: @escaping () -> TextFieldAlert
  ) -> some View {
    TextFieldWrapper(
      isShowing: isShowing,
      presentingView: self,
      content: content)
  }
}

struct TextFieldWrapper<PresentingView: View>: View {
  let isShowing: Bool
  let presentingView: PresentingView
  let content: () -> TextFieldAlert

  var body: some View {
    ZStack {
      if isShowing { content() }
      presentingView
    }
  }
}

private struct Preview: View {
  @State var isShowing: Bool = false
  @State var text: String = ""

  var body: some View {
    SwiftUIAlertInputViewController(
      title: "Enter some information here!", message: "What do you think?",
      placeholder: "info here...", initialInputText: "InitialName", onSave: { _ in },
      isShowing: $isShowing)
  }
}
struct TextFieldAlert_Previews: PreviewProvider {
  static var previews: some View {
    Preview()
  }
}
