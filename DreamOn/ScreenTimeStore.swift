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
import DeviceActivity



class ScreenTimeStore: ObservableObject {
    static let shared = ScreenTimeStore()
    private init() {}
    
    @AppStorage("selectedApps", store: UserDefaults(suiteName: "group.com.shield.dreamon"))
    var selectedApps = FamilyActivitySelection() {
        didSet {
            handleSetBlockApplication()
        }
    }
    
    let store = ManagedSettingsStore()
    let deviceActivityCenter = DeviceActivityCenter()

    func handleResetSelection() {
        selectedApps = FamilyActivitySelection()
    }
    
    func handleStartDeviceActivityMonitoring(includeUsageThreshold: Bool = true) {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        print("모니터링 등록시간: \(dateComponents)")
        
        // 새 스케쥴 시간 설정 - 하루
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: dateComponents.hour, minute: dateComponents.minute, second: dateComponents.second),
            intervalEnd: DateComponents(hour: dateComponents.hour! + 1, minute: dateComponents.minute, second: dateComponents.second),
            repeats: true
        )
        // 새 이벤트 생성
        let event = DeviceActivityEvent(
            applications: ScreenTimeStore.shared.selectedApps.applicationTokens,
            categories: ScreenTimeStore.shared.selectedApps.categoryTokens,
            webDomains: ScreenTimeStore.shared.selectedApps.webDomainTokens,
            // 앱 사용을 허용할 시간
            threshold: DateComponents(second: 10))
        do {
            try ScreenTimeStore.shared.deviceActivityCenter.startMonitoring(
                .daily,
                during: schedule,
                events: includeUsageThreshold ? [.tenSeconds: event] : [:]
            )
            print("Monitoring started")
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    func handleSetBlockApplication() {
        store.shield.applications = selectedApps.applicationTokens.isEmpty ? nil : selectedApps.applicationTokens
        store.shield.applicationCategories = selectedApps.categoryTokens.isEmpty
        ? nil
        : ShieldSettings.ActivityCategoryPolicy.specific(selectedApps.categoryTokens)
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

//MARK: Schedule Name List
extension DeviceActivityName {
    static let daily = Self("daily")
}

//MARK: Schedule Event Name List
extension DeviceActivityEvent.Name {
    static let tenSeconds = Self("threshold.seconds.ten")
}
