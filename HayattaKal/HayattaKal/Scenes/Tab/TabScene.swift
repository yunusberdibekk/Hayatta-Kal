//
//  TabScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct TabScene: BaseView {
    var body: some View {
        BaseBodyView {
            bodyView
        }
        .onAppear(perform:onAppear)
    }
    
    func onAppear() {
        
    }
}

#Preview {
    TabScene()
}
