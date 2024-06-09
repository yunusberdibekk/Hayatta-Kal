//
//  HayattaKalApp.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 4.04.2024.
//

import SwiftUI

@main
struct HayattaKalApp: App {
    @AppStorage("showLogin") var showLogin:Bool = true

    var body: some Scene {
        WindowGroup {
            if showLogin {
                AuthScene()
            } else {
                TabScene()
            }
        }
    }
}
