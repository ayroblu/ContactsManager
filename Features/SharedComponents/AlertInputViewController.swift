//
//  AlertInputViewController.swift
//  ContactsManager
//
//  Created by Ben Lu on 20/09/2022.
//

import SwiftUI

class AlertInputViewController: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    let alert = UIAlertController(
      title: "Alert Title", message: "Alert Message", preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.placeholder = "Default placeholder text"
    }

    alert.addAction(
      UIAlertAction(
        title: "Submit", style: .default,
        handler: { [weak alert] (_) in
          guard let textField = alert?.textFields?[0], let userText = textField.text else { return }
          print("User text: \(userText)")
        }))

    self.present(alert, animated: true, completion: nil)
  }
}
// TODO: https://stackoverflow.com/questions/56726663/how-to-add-a-textfield-to-alert-in-swiftui
struct SwiftUIAlertInputViewController: UIViewControllerRepresentable {
  typealias UIViewControllerType = AlertInputViewController
  let initialInputText: String

  func makeUIViewController(context: Context) -> AlertInputViewController {
    let vc = AlertInputViewController()
    return vc
  }

  func updateUIViewController(_ uiViewController: AlertInputViewController, context: Context) {

  }
}
