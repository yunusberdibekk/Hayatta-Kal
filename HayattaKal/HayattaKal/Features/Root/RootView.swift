//
//  RootView.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 4.04.2024.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView{
            ForEach(RootTabModel.rootTabModels){ model in
                model.page
                    .tabItem{
                        Label(model.item.title,
                              systemImage: model.item.image)
                    }
            }
        }
        
    }
}
struct RootTabModel: Identifiable{
    let id: String
    let page: AnyView
    let item: RootTabItem
    
    static var rootTabModels: [RootTabModel] = [
        .init(id: "1",
              page: AnyView(HomeView()),
              item: .init(title: "Home",
                          image: "house")),
        .init(id: "2",
              page: AnyView(TriangleFinderView()),
              item: .init(title: "Create",
                          image: "camera")),
        .init(id: "3",
              page: AnyView(SettingsView()),
              item: .init(title: "Settings",
                          image: "gear")),
    ]    
}
struct RootTabItem {
    let title: String
    let image: String
    
}
#Preview {
    RootView()
}
