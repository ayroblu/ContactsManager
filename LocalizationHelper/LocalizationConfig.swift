//
//  LocalizationConfig.swift
//  LocalizationHelper
//
//  Created by Ben Lu on 26/09/2022.
//

import Foundation

func runLocalization(with localizationHelper: LocalizationHelper) {
  localizationHelper.check()

  let fileManager = FileManager.default
  let projectDir = fileManager.currentDirectoryPath
  localizationHelper.translations.forEach { translation in
    let filePath = NSString.path(withComponents: [
      projectDir,
      "ContactsManager/\(translation.languageCode).lproj/\(localizationHelper.fileName)",
    ])
    if !fileManager.fileExists(atPath: filePath) {
      print("could not find: \(filePath)")
      return
    }
    if !fileManager.isWritableFile(atPath: filePath) {
      print("file not writable: \(filePath)")
      return
    }
    let str = translation.getStringsFileText()
    // swiftlint:disable force_try
    try! str.write(
      to: URL(fileURLWithPath: filePath), atomically: true, encoding: String.Encoding.utf8)
  }
  let languageCodes = Set(localizationHelper.translations.map { $0.languageCode })
  let targetPath = NSString.path(withComponents: [
    projectDir, "ContactsManager",
  ])
  let targetUrl = URL(fileURLWithPath: targetPath)
  if let directoryContents = try? fileManager.contentsOfDirectory(
    at: targetUrl,
    includingPropertiesForKeys: [URLResourceKey.isDirectoryKey]
  ) {
    let directoryKeys = Set(
      directoryContents.filter { $0.lastPathComponent.hasSuffix(".lproj") }.map {
        $0.lastPathComponent.replacingOccurrences(of: ".lproj", with: "")
      })
    let missingTranslationConfigs = Array(directoryKeys.subtracting(languageCodes)).sorted()
    if !missingTranslationConfigs.isEmpty {
      print("Missing configs for: \(missingTranslationConfigs)")
    }
  } else {
    print("Failed to fetch directory contents for \(targetPath)")
  }
}
