//
//  MultiInsertListView.swift
//  ContactsManager
//
//  Created by Ben Lu on 12/09/2022.
//

import SwiftUI

struct MultiInsertListView: View {
  let insertLabel: String

  @Binding var options: [String]
  @State var text: String = ""
  @Environment(\.colorScheme) var colorScheme
  @FocusState private var focusField: Int?

  var body: some View {
    ForEach(options.indices, id: \.self) { index in
      HStack {
        Button(action: { options.remove(at: index) }) {
          Image(systemName: "minus.circle.fill").foregroundColor(.red)
        }
        let binding = Binding(
          get: { options[index] },
          set: { options[index] = $0 })
        TextField("", text: binding)
          .focused($focusField, equals: index)
      }
    }
    Button(action: {
      options.insert("", at: options.count)
      focusField = options.count - 1
    }) {
      HStack {
        Image(systemName: "plus.circle.fill").foregroundColor(.green)
        Text(insertLabel)
      }
    }.foregroundStyle(colorScheme == .dark ? .white : .black)
  }
}

struct MultiInsertListView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(ColorScheme.allCases, id: \.self) {
      PreviewRender()
        .preferredColorScheme($0)
    }
  }
}

private struct PreviewRender: View {
  @State private var options: [String] = []

  var body: some View {
    List {
      MultiInsertListView(insertLabel: "add item", options: $options)
    }
  }
}
