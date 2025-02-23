//
//  BarcodeTextScannerApp.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import SwiftUI
    
@main
struct BarcodeTextScannerApp: App {
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.colorScheme, .dark)
        }
    }
}
