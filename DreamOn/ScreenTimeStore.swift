//
//  ScreenTimeStore.swift
//  DreamOn
//
//  Created by Yun Dongbeom on 2023/05/05.
//


import SwiftUI
import Foundation
import FamilyControls
import ManagedSettings



class ScreenTimeStore: ObservableObject {
    static let shared = ScreenTimeStore()
    private init() {}
    
    @AppStorage("selectedApps", store: UserDefaults(suiteName: "group.com.shield.dreamon"))
    var selectedApps = FamilyActivitySelection() {
        didSet {
            print("changed..!")
        }
    }
    
    let store = ManagedSettingsStore()

}

//MARK: FamilyActivitySelection Parser
extension FamilyActivitySelection: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
