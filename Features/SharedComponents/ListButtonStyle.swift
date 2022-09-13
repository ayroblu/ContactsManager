//
//  ListButtonStyle.swift
//  ContactsManager
//
//  Created by Ben Lu on 13/09/2022.
//

import SwiftUI

struct ListButtonStyle: ButtonStyle {
  @Environment(\.colorScheme) var colorScheme

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundStyle(colorScheme == .dark ? .white : .black)
  }
}
