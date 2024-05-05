//
//  OnboardingViewModel.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 4.04.2024.
//

import Foundation
import SwiftUI

// Define a struct representing an onboarding step with an image, title, and description
struct OnboardingStep {
    let image: String
    let title: String
    let description: String
}

// Define onboarding steps with images and descriptions
private let onBoardingSteps = [
    OnboardingStep(image: "Onboarding1", title: "", description: "Depremden önce güvenliğin için önlemini al"),
    OnboardingStep(image: "Onboarding2", title: "", description: "Deprem anında yapacaklarını belirle!"),
    OnboardingStep(image: "Onboarding3", title: "", description: "Deprem sonrasında güvende olduğunu sevdiklerine bildir")
]

// Define ContentView struct, which represents the main view
struct ContentView: View {
    // State variable to keep track of the current step in onboarding
    @State private var currentStep = 0
    
    // Initialize the ContentView struct
    init() {
        // Disable bouncing in UIScrollView to prevent overscrolling
        UIScrollView.appearance().bounces = false
    }
    
    // Define the body of the ContentView
    var body: some View {
        VStack {
            // Display a 'Skip' button at the top-right corner
            HStack {
                Spacer()
                Button(action: {
                    // Set currentStep to the last step index to skip onboarding
                    self.currentStep = onBoardingSteps.count - 1
                }) {
                    Text("Skip")
                        .padding(16)
                        .foregroundColor(.blue)
                }
            }
            
            // Display onboarding steps in a TabView
            TabView(selection: $currentStep) {
                ForEach(0..<onBoardingSteps.count) { index in
                    VStack {
                        // Display onboarding step image
                        Image(onBoardingSteps[index].image)
                            .resizable()
                            .frame(width: 250, height: 250)
                        
                        // Display onboarding step description
                        Text(onBoardingSteps[index].description)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                    // Tag each view with its index
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Display indicators for each onboarding step
            HStack {
                ForEach(0..<onBoardingSteps.count) { index in
                    if index == currentStep {
                        Rectangle()
                            .frame(width: 20, height: 10)
                            .cornerRadius(10)
                            .foregroundColor(.blue)
                    } else {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.bottom, 94)
            
            // Display 'Next' or 'Get Started' button
            Button(action: {
                if self.currentStep < onBoardingSteps.count - 1 {
                    // Increment currentStep to move to the next onboarding step
                    self.currentStep += 1
                } else {
                    // Perform action for 'Get Started' logic
                }
            }) {
                Text(currentStep < onBoardingSteps.count - 1 ? "Next" : "Get Started")
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(100)
                    .padding(.horizontal, 16)
                    .foregroundColor(.white)
                    .padding(.bottom, 144)
                    .frame(width: 300, height: 60)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .background(Color.white)
    }
}

// Define ContentView_PreviewProvider for previewing ContentView
struct ContentView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
