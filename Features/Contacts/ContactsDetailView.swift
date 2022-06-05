//
//  ContactsDetailView.swift
//  ContactsManager
//
//  Created by Ben Lu on 04/06/2022.
//

import SwiftUI

struct ContactsDetailView: View {
    let item: FetchedResults<Item>.Element
    var body: some View {
        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
    }
}
