//
//  OnboardingScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct OnboardingScene: BaseView {
    @StateObject var viewModel: OnboardingViewModel = .init()
    
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
    OnboardingScene()
}
