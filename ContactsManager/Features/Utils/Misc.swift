//
//  Misc.swift
//  ContactsManager
//
//  Created by Ben Lu on 24/09/2022.
//

import Foundation

func getHash<T: Hashable>(for item: T) -> Int {
  var hasher = Hasher()
  hasher.combine(item)
  return hasher.finalize()
}
