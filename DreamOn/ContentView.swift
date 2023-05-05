//
//  ContentView.swift
//  DreamOn
//
//  Created by Yun Dongbeom on 2023/05/05.
//

import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

struct ContentView: View {
    
    @ObservedObject
    var store: ScreenTimeStore
        
    @State
    var isShieldedAppPickerPresented = false
    
    var body: some View {
        ScrollView() {
            VStack {
                CustomButtonView(
                    buttonName: "Request Authorization",
                    buttonColor: .orange) {
                    reqScreenTimePermission()
                }
                CustomButtonView(
                    buttonName: "Request Notifications Permission",
                    buttonColor: .cyan) {
                    reqNotificationPermission()
                }
                CustomButtonView(
                    buttonName: "Reset Shielded Apps",
                    buttonColor: .pink) {
                    handleResetSelection()
                    
                }
                CustomButtonView(
                    buttonName: "Select Apps to Shield",
                    buttonColor: .orange) {
                    isShieldedAppPickerPresented.toggle()
                }
                .familyActivityPicker(headerText: "헤더명", isPresented: $isShieldedAppPickerPresented, selection: ScreenTimeStore.shared.$selectedApps)
                
                if let firstToken = ScreenTimeStore.shared.selectedApps.applicationTokens.first {
                    Label(firstToken)
                        .frame(maxWidth: .infinity)
                        .labelStyle(.iconOnly)
                } else {
                    Text("선택된 앱이 없습니다.")
                }
                CustomButtonView(
                    buttonName: "Start Shield",
                    buttonColor: .red) {
                        handleStartDeviceActivityMonitoring()
                }
                CustomButtonView(
                    buttonName: "Block Shield",
                    buttonColor: .teal) {
                        handleSetBlockApplication()
                }
                CustomButtonView(
                    buttonName: "Schedule List",
                    buttonColor: .teal) {
                        print(ScreenTimeStore.shared.deviceActivityCenter.activities)
                        let activityName = ScreenTimeStore.shared.deviceActivityCenter.activities[0]
                        
                        print(ScreenTimeStore.shared.deviceActivityCenter.schedule(for: activityName) ?? "not")
                        print(ScreenTimeStore.shared.deviceActivityCenter.events(for: activityName))
                        
                }
//                if ScreenTimeStore.shared.selectedApps.applicationTokens.count > 0 {
//
//                }
            }
//            VStack {
//                // FamilyActivityPicker 를 밖으로 뺄 수 있다.
//                FamilyActivityPicker(selection: store.$selectedApps)
//                    .tint(.indigo)
//                    .frame(height: 400)
//                    .onChange(of: store.selectedApps) { newSelection in
//                        print(newSelection)
//                        let token = newSelection.applicationTokens
//                        print(token.count)
//                    }
//
//             }
        }
    }
}

//MARK: Views
extension ContentView {
    // MARK: CustomButtonView - 공통으로 사용되는 버튼뷰
    private func CustomButtonView(
            buttonName: String,
            buttonColor: Color,
            action: @escaping ()->() = {
                print("Button Click")
            }
        ) -> some View {
        Button {
            action()
        } label: {
            Text(buttonName)
                .font(.headline)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(buttonColor)
    }
}

//MARK: Method
extension ContentView {
    
    //MARK: 스크린타임 권한 요청
    private func reqScreenTimePermission() {
        let center = AuthorizationCenter.shared
        
        if center.authorizationStatus == .approved {
            print("ScreenTime Permission approved")
        } else {
            Task {
                do {
                     try await center.requestAuthorization(for: .individual)
                 } catch {
                     print("Failed to enroll Aniyah with error: \(error)")
                     // 사용자가 허용안함.
                     // Error Domain=FamilyControls.FamilyControlsError Code=5 "(null)
                 }
            }
        }
    }
    
    //MARK: 유저노티피케이션 권한 요청
    private func reqNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.alertSetting {
                case .enabled:
                    print("Notification Permission approved")
                default:
                    print("not..!")
                Task {
                    do {
                        try await center.requestAuthorization(options: [.alert, .badge, .sound])
                    } catch {
                        print("Failed to enroll Aniyah with error: \(error)")
                    }
                    
                }
            }
        }

    }
    //MARK: 현재 선택된 앱 초기화
    private func handleResetSelection() {
        ScreenTimeStore.shared.handleResetSelection()
        handleStartDeviceActivityMonitoring(includeUsageThreshold: false)
    }
    
    //MARK: 앱 제한 모니터링 등록 및 시작
    private func handleStartDeviceActivityMonitoring(includeUsageThreshold: Bool = true) {
        ScreenTimeStore.shared.handleStartDeviceActivityMonitoring(includeUsageThreshold: includeUsageThreshold)
    }
    
    private func handleSetBlockApplication() {
        ScreenTimeStore.shared.handleSetBlockApplication()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: ScreenTimeStore.shared)
    }
}
