//
//  HomeView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 22/02/25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("preference") var preference: String?
    @StateObject var vm: AppScannerViewModel = .shared
    
    var body: some View {
        if preference != nil {
            ContentView()
                .environmentObject(vm)
                .onAppear {
                    Task {
                        await vm.requestCameraAccess()
                    }
                }
        } else {
            OnboardingView()
        }
    }
}
