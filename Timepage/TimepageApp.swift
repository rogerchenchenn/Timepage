//
//  TimepageApp.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI

@main
struct TimepageApp: App {
    @Environment(\.scenePhase) var phase
    
    private let parameters = appParameters()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(parameters)
                
        }.windowStyle(HiddenTitleBarWindowStyle())
        
        #if os(macOS)
            Settings{
              SettingsView().environmentObject(parameters)
            }
        #endif
        
    }
}
