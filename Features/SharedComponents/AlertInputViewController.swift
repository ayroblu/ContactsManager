//
//  AlertInputViewController.swift
//  ContactsManager
//
//  Created by Ben Lu on 20/09/2022.
//

import SwiftUI

class AlertInputViewController: UIViewController {
  private let alertTitle: String?
  private let message: String?
  private let placeholder: String?
  private let initialText: String?
  private let onSubmit: (String) -> Void
  private var isShowing: Binding<Bool>

  init(
    alertTitle: String?, message: String?, placeholder: String?, initialText: String?,
    isShowing: Binding<Bool>, onSubmit: @escaping (String) -> Void
  ) {
    self.alertTitle = alertTitle
    self.message = message
    self.placeholder = placeholder
    self.initialText = initialText
    self.isShowing = isShowing
    self.onSubmit = onSubmit
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //  private var isPresented: Binding<Bool>?
  override func viewDidAppear(_ animated: Bool) {
    let alert = UIAlertController(
      title: alertTitle, message: message, preferredStyle: .alert)

    alert.addTextField { (textField) in
      textField.placeholder = self.placeholder
      textField.text = self.initialText
    }

    alert.addAction(
      UIAlertAction(
        title: "Dismiss", style: .cancel,
        handler: { [weak alert] (_) in
          guard let textField = alert?.textFields?[0], let userText = textField.text else { return }
          print("User text: \(userText)")
          self.isShowing.wrappedValue = false
        }))

    alert.addAction(
      UIAlertAction(
        title: "Submit", style: .default,
        handler: { [weak alert] (_) in
          guard let textField = alert?.textFields?[0], let userText = textField.text else { return }
          //          print("User text: \(userText)")
          self.isShowing.wrappedValue = false
          self.onSubmit(userText)
        }))

    self.present(alert, animated: true, completion: nil)
  }
}
// TODO: https://stackoverflow.com/questions/56726663/how-to-add-a-textfield-to-alert-in-swiftui
struct SwiftUIAlertInputViewController: UIViewControllerRepresentable {
  typealias UIViewControllerType = AlertInputViewController
  let title: String
  let message: String?
  let placeholder: String?
  let initialInputText: String
  let onSave: (String) -> Void
  let isShowing: Binding<Bool>

  func makeUIViewController(context: Context) -> AlertInputViewController {
    AlertInputViewController(
      alertTitle: title, message: message, placeholder: placeholder, initialText: initialInputText,
      isShowing: isShowing, onSubmit: onSave)
  }

  func updateUIViewController(_ uiViewController: AlertInputViewController, context: Context) {

  }
}
