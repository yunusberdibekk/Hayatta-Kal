//
//  AuthScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct AuthScene: View {
    @AppStorage("showOnboarding") var showOnboarding:Bool = true

    var body: some View {
        if showOnboarding {
            OnboardingScene()
        } else {
            LoginScene()
        }
    }
}

#Preview {
    AuthScene()
}

