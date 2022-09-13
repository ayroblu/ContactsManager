//
//  SwiftCNContactViewController.swift
//  ContactsManager
//
//  Created by Ben Lu on 13/09/2022.
//

import Contacts
import ContactsUI
import SwiftUI

struct SwiftCNContactViewController: UIViewControllerRepresentable {
  typealias UIViewControllerType = CNContactViewController
  let contact: CNContact

  func makeUIViewController(context: Context) -> CNContactViewController {
    let vc = CNContactViewController(for: contact)
    vc.allowsActions = true
    return vc
  }

  func updateUIViewController(_ uiViewController: CNContactViewController, context: Context) {

  }
}
