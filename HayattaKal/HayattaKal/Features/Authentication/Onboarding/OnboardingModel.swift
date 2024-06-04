//
//  OnboardingModel.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 20.05.2024.
//

import Foundation

// Define a struct representing an onboarding step with an image, title, and description
struct OnboardingModel{
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
