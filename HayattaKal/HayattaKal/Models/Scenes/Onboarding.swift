//
//  Onboarding.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import Foundation

struct OnboardingModel:Identifiable{
    let id = UUID().uuidString
    let image: String
    let title: String
    let description: String
    
    static let items = [
        OnboardingModel(
            image: "Onboarding1",
            title: "",
            description: "Depremden önce güvenliğin için önlemini al"
        ),
        OnboardingModel(
            image: "Onboarding2",
            title: "",
            description: "Deprem anında yapacaklarını belirle!"
        ),
        OnboardingModel(
            image: "Onboarding3",
            title: "",
            description: "Deprem sonrasında güvende olduğunu sevdiklerine bildir"
        )
    ]
}
