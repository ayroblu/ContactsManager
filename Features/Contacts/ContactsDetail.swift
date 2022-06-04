//
//  ContactsDetail.swift
//  ContactsManager
//
//  Created by Ben Lu on 04/06/2022.
//

import SwiftUI

struct ContactsDetail: View {
    let item: FetchedResults<Item>.Element
    var body: some View {
        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
    }
}
