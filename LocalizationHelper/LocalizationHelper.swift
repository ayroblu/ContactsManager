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

  func check() {
    translations.forEach { translation in
      print("LocalizationHelper: start translation for \(translation.languageCode)")
      let mappingKeys = Set(translation.mappings.map { $0.key })
      let missingMappingKeys = base.subtracting(mappingKeys)
      let missingBaseKeys = mappingKeys.subtracting(base)
      if !missingMappingKeys.isEmpty {
        print("\(translation.languageCode) is missing keys: \(Array(missingMappingKeys).sorted())")
      }
      if !missingBaseKeys.isEmpty {
        print("\(translation.languageCode) has extra keys: \(Array(missingBaseKeys).sorted())")
      }
      print("---")
    }
  }
}

struct Translation {
  let languageCode: String
  let mappings: [String: String]

  func getStringsFileText() -> String {
    mappings.map { (key, value) in "\"\(key)\" = \"\(value)\";" }.joined(separator: "\n")
  }
}
