//
//  MovieAppApp.swift
//  MovieApp
//
//  Created by Rikkei on 14/05/2025.
//

import SwiftUI

@main
struct MovieAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
        }
    }
}
