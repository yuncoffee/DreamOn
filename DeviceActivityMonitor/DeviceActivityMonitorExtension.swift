//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitor
//
//  Created by Yun Dongbeom on 2023/05/06.
//

import DeviceActivity
import ManagedSettings
import Foundation
//import UserNotifications
import SwiftUI
import FamilyControls

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    @AppStorage("shieldedApps", store: UserDefaults(suiteName: "group.com.shield.dreamon")) var shieldedApps = FamilyActivitySelection()
    
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Handle the start of the interval.
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Handle the end of the interval.
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        let store = ManagedSettingsStore()
        store.shield.applications = shieldedApps.applicationTokens
        store.shield.applicationCategories = .specific(shieldedApps.categoryTokens)
        
        
        // Handle the event reaching its threshold.
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
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
