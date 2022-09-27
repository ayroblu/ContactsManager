//
//  main.swift
//  LocalizationHelper
//
//  Created by Ben Lu on 26/09/2022.
//

import Foundation

let mainLocalizationHelper = LocalizationHelper(
  base: enBase,
  translations: [
    Translation(languageCode: "ar", mappings: ar),
    Translation(languageCode: "en", mappings: en),
    Translation(languageCode: "en-GB", mappings: enGB),
    Translation(languageCode: "es", mappings: es),
    Translation(languageCode: "fr", mappings: fr),
    Translation(languageCode: "zh-HK", mappings: zhHK),
  ], fileName: "Localizable.strings")
runLocalization(with: mainLocalizationHelper)

let infoPlistLocalizationHelper = LocalizationHelper(
  base: enBaseInfo,
  translations: [
    Translation(languageCode: "ar", mappings: arInfo),
    Translation(languageCode: "en", mappings: enInfo),
    Translation(languageCode: "en-GB", mappings: enGBInfo),
    Translation(languageCode: "es", mappings: esInfo),
    Translation(languageCode: "fr", mappings: frInfo),
    Translation(languageCode: "zh-HK", mappings: zhHKInfo),
  ], fileName: "InfoPlist.strings")
runLocalization(with: infoPlistLocalizationHelper)
