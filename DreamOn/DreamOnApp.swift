//
//  DreamOnApp.swift
//  DreamOn
//
//  Created by Yun Dongbeom on 2023/05/05.
//

import SwiftUI

@main
struct DreamOnApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: ScreenTimeStore.shared)
        }
    }
}
