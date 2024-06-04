//
//  SettingsView.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 4.04.2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var profileImage: Image?
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var isLoggedIn: Bool = true // Örnek olarak true olarak varsayalım, kullanıcı oturum açtı kabul edelim.

    var body: some View {
        VStack {
            ProfileSection(profileImage: $profileImage, firstName: $firstName, lastName: $lastName)
            Spacer()
            NavigationSection(isLoggedIn: $isLoggedIn)
            Spacer()
        }
    }
}

struct ProfileSection: View {
    @Binding var profileImage: Image?
    @Binding var firstName: String
    @Binding var lastName: String
    
    var body: some View {
        HStack {
            if let image = profileImage {
                image
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .padding(30)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .padding(30)
            }
            
            VStack(alignment: .leading) {
                TextField("First Name", text: $firstName)
            }
        }
    }
}

struct NavigationSection: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 50) {
            NavigationButton(title: "Profile")
            NavigationButton(title: "Information")
            NavigationButton(title: "Notifications")
            NavigationButton(title: "Privacy and Security")
            NavigationButton(title: "About Us")
            NavigationButton(title: "Log Out", isDestructive: true) {
                isLoggedIn = false // Oturum kapatıldı olarak kabul edelim
            }
        }
        .padding()
    }
}

struct NavigationButton: View {
    var title: String
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            Text(title)
                .foregroundColor(isDestructive ? .color3 : .primary)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
