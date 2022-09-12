//
//  MultiSelectionListView.swift
//  ContactsManager
//
//  Created by Ben Lu on 12/09/2022.
//

import SwiftUI

struct MultiSelectionListView<Selectable: Identifiable & Hashable>: View {
  let options: [Selectable]
  let optionToString: (Selectable) -> String

  @Environment(\.colorScheme) var colorScheme
  @Binding var selected: Set<Selectable>

  var body: some View {
    ForEach(options) { selectable in
      Button(action: { toggleSelection(selectable: selectable) }) {
        HStack {
          if selected.contains { $0.id == selectable.id } {
            Image(
              systemName: "checkmark.circle.fill"
            ).foregroundColor(.accentColor)
          } else {
            Image(systemName: "circle").foregroundColor(.gray)
          }
          Text(optionToString(selectable))
        }
      }.tag(selectable.id).foregroundStyle(colorScheme == .dark ? .white : .black)
    }
  }

  private func toggleSelection(selectable: Selectable) {
    if selected.contains(where: { $0.id == selectable.id }) {
      selected.remove(selectable)
    } else {
      selected.insert(selectable)
    }
  }
}

struct MultiSelectionListView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(ColorScheme.allCases, id: \.self) {
      PreviewRender()
        .preferredColorScheme($0)
    }
  }
}

private struct PreviewRender: View {
  @State private var selected: Set<String> = []

  var body: some View {
    List {
      MultiSelectionListView(
        options: ["First", "Second", "Third"], optionToString: { o in o }, selected: $selected)
    }
  }
}

extension String: Identifiable {
  public var id: String { self }
}
