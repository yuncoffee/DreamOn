//
//  DeviceActiviryReport.swift
//  DeviceActiviryReport
//
//  Created by Yun Dongbeom on 2023/05/05.
//

import DeviceActivity
import SwiftUI

@main
struct DeviceActiviryReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
