//
//  Utils.swift
//  ContactsManager
//
//  Created by Ben Lu on 04/06/2022.
//

import Foundation

let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
