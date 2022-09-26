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

  @Binding var selections: [Selectable.ID: SelectSelection]

  var body: some View {
    ForEach(options) { selectable in
      Button(action: { toggleSelection(selectable: selectable) }) {
        HStack {
          let selection = selections[selectable.id]
          switch selection {
          case .Selected:
            Image(
              systemName: "checkmark.circle.fill"
            ).foregroundColor(.accentColor)
          case .MixedSelected:
            Image(
              systemName: "minus.circle.fill"
            ).foregroundColor(.accentColor)
          case .Unselected, nil:
            Image(systemName: "circle").foregroundColor(.gray)
          }
          Text(optionToString(selectable))
          Spacer()
        }
      }.tag(selectable.id).buttonStyle(ListButtonStyle())
    }
  }

  private func toggleSelection(selectable: Selectable) {
    let selection = selections[selectable.id]
    switch selection {
    case .Selected:
      selections[selectable.id] = .Unselected
    case .MixedSelected:
      selections[selectable.id] = .Unselected
    case .Unselected, nil:
      selections[selectable.id] = .Selected
    }
  }
}

enum SelectSelection {
  case Selected
  case Unselected
  case MixedSelected
}
typealias SelectionMap = [String: SelectSelection]

struct MultiSelectionListView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(ColorScheme.allCases, id: \.self) {
      PreviewRender()
        .preferredColorScheme($0)
    }
  }
}

private struct PreviewRender: View {
  @State private var selections: [String: SelectSelection] = [:]

  var body: some View {
    List {
      MultiSelectionListView(
        options: ["First", "Second", "Third"], optionToString: { o in o }, selections: $selections)
    }
  }
}

extension String: Identifiable {
  public var id: String { self }
}
