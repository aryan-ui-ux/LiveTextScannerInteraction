//
//  HomeView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 22/02/25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("preference") private var preference: String?
    @StateObject private var vm: AppViewModel = .shared
    
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
