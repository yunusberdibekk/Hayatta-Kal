//
//  OnboardingView.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 4.04.2024.
//

import SwiftUI

struct OnboardingView: View {
    // State variable to keep track of the current step in onboarding
    @State private var currentStep = 0

    // Define the body of the ContentView
    var body: some View {
        VStack {
            // Display onboarding steps in a TabView
            TabView(selection: $currentStep) {
                ForEach(0..<OnboardingModel.items.count, id: \.self) { index in
                    VStack {
                        // Display onboarding step image
                        Image(OnboardingModel.items[index].image)
                            .resizable()
                            .frame(width: 280, height: 250)

                        // Display onboarding step description
                        Text(OnboardingModel.items[index].description)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 62)
                            .foregroundColor(.color3)
                            .font(.title)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            // Display indicators for each onboarding step
            HStack {
                ForEach(0..<OnboardingModel.items.count, id: \.self) { index in
                    if index == currentStep {
                        Rectangle()
                            .frame(width: 20, height: 10)
                            .cornerRadius(10)
                            .foregroundColor(Color("Color1"))
                    } else {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.bottom, 94)
            
            Button {
                if currentStep < OnboardingModel.items.count - 1 {
                    self.currentStep += 1
                } else {
                    // Perform action for 'Get Started' logic
                }
            } label: {
                Text(currentStep < OnboardingModel.items.count - 1 ? "Next" : "Get Started")
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(
                        colors: [
                            .color1,
                            .color2
                        ], startPoint: .leading, endPoint: .trailing
                    ))
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

#Preview {
    OnboardingView()
}
