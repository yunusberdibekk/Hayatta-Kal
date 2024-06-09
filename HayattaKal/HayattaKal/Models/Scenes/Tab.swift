//
//  Tab.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct TabModel: Identifiable{
    let id: String
    let page: AnyView
    let item: RootTabItem
    
    static var tabModels: [TabModel] = [
        .init(id: "1",
              page: AnyView(TriangleScene()),
              item: .init(title: "Home",
                          image: .house)),
        .init(id: "2",
              page: AnyView(TriangleScene()),
              item: .init(title: "Create",
                          image: .camera)),
        .init(id: "3",
              page: AnyView(TriangleScene()),
              item: .init(title: "Settings",
                          image:.gear)),
    ]
}
struct RootTabItem {
    let title: String
    let image: SFSymbol
}
