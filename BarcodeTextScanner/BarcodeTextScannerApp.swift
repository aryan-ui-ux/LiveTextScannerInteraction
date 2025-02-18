//
//  BarcodeTextScannerApp.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import SwiftUI
    
// MARK: - App
@main
struct BarcodeTextScannerApp: App {
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.colorScheme, .dark)
        }
    }
}

struct HomeView: View {
    @AppStorage("preference") private var preference: String?
    @StateObject private var vm = AppViewModel()
    
    var body: some View {
        if preference != nil {
            ContentView()
                .environmentObject(vm)
                .onAppear {
                    Task {
                        await vm.requestDataScannerAccessStatus()
                    }
                }
        } else {
            OnboardingView()
        }
    }
}
