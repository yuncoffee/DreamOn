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
                    buttonName: "Select Apps to Shield",
                    buttonColor: .orange) {
                    isShieldedAppPickerPresented.toggle()
                }
                    .familyActivityPicker(headerText: "헤더명", isPresented: $isShieldedAppPickerPresented, selection: ScreenTimeStore.shared.$selectedApps)
                if store.selectedApps.applicationTokens.count > 0 {
                    if let firstToken = store.selectedApps.applicationTokens.first {
                        Label(firstToken)
                            .frame(maxWidth: .infinity)
                            .labelStyle(.iconOnly)
                    } else {
                        
                    }
                }
            }
            .padding()
//            FamilyActivityPicker(selection: $selectedApps)
            VStack {
                // FamilyActivityPicker 를 밖으로 뺄 수 있다.
                FamilyActivityPicker(selection: ScreenTimeStore.shared.$selectedApps)
                    .tint(.indigo)
                    .frame(height: 400)
             }
            .onChange(of: store.selectedApps) { newSelection in
//                let applications = store.selectedApps.applications
                let token = store.selectedApps.applicationTokens
//                print(applications.count)
//                print(applications)
                print(token.count)
//                tokens = token
             }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: ScreenTimeStore.shared)
    }
}
