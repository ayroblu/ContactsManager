//
//  LocalizationConfig.swift
//  LocalizationHelper
//
//  Created by Ben Lu on 26/09/2022.
//

import Foundation

func run() {
  let localizationHelper = LocalizationHelper(
    base: en,
    translations: [
      Translation(languageCode: "fr", mappings: fr),
      Translation(languageCode: "es", mappings: es),
    ])
  localizationHelper.check()

  let fileManager = FileManager.default
  let projectDir = fileManager.currentDirectoryPath
  localizationHelper.translations.forEach { translation in
    let filePath = NSString.path(withComponents: [
      projectDir, "ContactsManager/\(translation.languageCode).lproj/Localizable.strings",
    ])
    if !fileManager.fileExists(atPath: filePath) {
      print("could not find: \(filePath)")
    }
    if !fileManager.isWritableFile(atPath: filePath) {
      print("file not writable: \(filePath)")
    }
    let str = translation.getStringsFileText()
    // swiftlint:disable force_try
    try! str.write(
      to: URL(fileURLWithPath: filePath), atomically: true, encoding: String.Encoding.utf8)
  }
}
