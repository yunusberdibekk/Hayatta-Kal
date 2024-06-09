//
//  OnboardingViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @AppStorage("showOnboarding") var showOnboarding:Bool = true
    @Published var currentStep:Int = .zero
}
