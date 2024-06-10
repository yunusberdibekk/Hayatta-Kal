//
//  Profile+UI.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 10.06.2024.
//

import SwiftUI

extension ProfileScene {
    var bodyView: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    userInfosView

                    settingsView

                    Spacer()
                }
                .navigationTitle("Profile")
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    var userInfosView: some View {
        if let user = viewModel.currentUser {
            HStack {
                if let image = user.imagePath {
                    AsyncImage(url: .init(string: image)) { returnedImage in
                        returnedImage
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .padding(30)
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .padding(30)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(user.name + " " + user.surname)
                        .font(.headline)

                    Text(user.email)
                        .font(.callout)
                }
                .fontWeight(.heavy)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.orange1, style: .init(lineWidth: 2))
                )
            }
        }
    }

    var settingsView: some View {
        VStack(spacing: 20) {
            settingsItem(title: "Profile", action: nil)
            
            settingsItem(title: "Information", action: nil)
            
            settingsItem(title: "Notifications", action: nil)
            
            settingsItem(title: "Privacy and Security", action: nil)
            
            settingsItem(title: "About Us", action: nil)
            
            settingsItem(title: "Log Out") {
                viewModel.showLogin = true
            }
        }
        .padding(.horizontal)
    }

    func settingsItem(title: String, action: (() -> Void)?) -> some View {
        Button(action: {
            action?()
        }, label: {
            Text(title)
                .versionForegroundColor(.gray3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.orange1, style: .init(lineWidth: 1))
                )
        })
    }
}
