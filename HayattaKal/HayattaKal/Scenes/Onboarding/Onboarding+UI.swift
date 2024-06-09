//
//  Onboarding+UI.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

extension OnboardingScene {
    var bodyView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                tabView
                
                customIndicatorsView
                
                getStartedView
                
                Spacer()
            }
        }
    }
    
    var tabView: some View {
        TabView(selection: $viewModel.currentStep) {
            ForEach(0..<OnboardingModel.items.count, id:\.self) { index in
                onboardingItemView(item: OnboardingModel.items[index],
                                   index: index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    func onboardingItemView(item: OnboardingModel, index:Int) -> some View {
        VStack {
            Image(item.image)
                .resizable()
                .frame(width: 280, height: 250)
            
            Text(item.description)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.vertical, 62)
                .foregroundColor(.orange3)
                .font(.title)
        }
        .tag(index)
    }
    
    var customIndicatorsView: some View {
        HStack {
            ForEach(0..<OnboardingModel.items.count, id: \.self) { index in
                if index == viewModel.currentStep {
                    Rectangle()
                        .frame(width: 20, height: 10)
                        .cornerRadius(10)
                        .foregroundColor(.orange1)
                } else {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.bottom, 94)
    }
    
    
    var getStartedView : some View {
        Button {
            if viewModel.currentStep < OnboardingModel.items.count - 1 {
                self.viewModel.currentStep += 1
            } else {
                self.viewModel.showOnboarding = false
            }
        } label: {
            Text(viewModel.currentStep < OnboardingModel.items.count - 1 ? "Next" : "Get Started")
                .authButtonModifier(foregroundColor: .white,
                                    colors: [.orange1, .orange2],
                                    size: CGSize(width: 300, height: 60),
                                    radius: 100)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}


#Preview {
    OnboardingScene()
}

