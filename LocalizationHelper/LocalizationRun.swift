//
//  LocalizationRun.swift
//  LocalizationHelper
//
//  Created by Ben Lu on 26/09/2022.
//

import Foundation

func run() {
  let localizationHelper = LocalizationHelper(
    base: en,
    translations: [
      Translation(languageCode: "fr", mappings: fr)
    ])
  localizationHelper.check()

  let fileManager = FileManager.default
  let projectDir = fileManager.currentDirectoryPath
  localizationHelper.translations.forEach { translation in
    let filePath = NSString.path(withComponents: [
      projectDir, "ContactsManager/\(translation.languageCode).lproj/Localizable.strings",
    ])
    // Check if file exists
    if fileManager.fileExists(atPath: filePath) {
      print("File exists")
    } else {
      print("could not find: \(filePath)")
    }
  }
}

let en: Set<String> = ["Groups"]

let fr = ["Groups": "Groupes"]
