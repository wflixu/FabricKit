//
//  FabricApp.swift
//  Fabric
//
//  Created by 李旭 on 2025/4/12.
//

import SwiftUI
import OSLog
import Combine

let logger = Logger(subsystem: "com.wflixu.fabric", category: "FabricApp")

@main
struct FabricApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
