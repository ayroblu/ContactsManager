//
//  LocalizationHelper.swift
//  LocalizationHelper
//
//  Created by Ben Lu on 26/09/2022.
//

import Foundation

struct LocalizationHelper {
  let base: Set<String>
  let translations: [Translation]
  let fileName: String

  func check() {
    translations.forEach { translation in
      let mappingKeys = Set(translation.mappings.map { $0.key })
      let missingMappingKeys = base.subtracting(mappingKeys)
      let missingBaseKeys = mappingKeys.subtracting(base)
      if !missingMappingKeys.isEmpty {
        print("\(translation.languageCode) is missing keys: \(Array(missingMappingKeys).sorted())")
      }
      if !missingBaseKeys.isEmpty {
        print("\(translation.languageCode) has extra keys: \(Array(missingBaseKeys).sorted())")
      }
    }
  }
}

struct Translation {
  let languageCode: String
  let mappings: [String: String]

  func getStringsFileText() -> String {
    mappings.map { (key, value) in
      "\"\(escapeQuotes(str: key))\" = \"\(escapeQuotes(str: value))\";"
    }.sorted().joined(separator: "\n")
  }
  private func escapeQuotes(str: String) -> String {
    str.replacingOccurrences(of: "\"", with: "\\\"")
  }
}
