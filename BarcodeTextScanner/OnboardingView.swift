//
//  OnboardingView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 17/02/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                SafeBackgroundView()
                    .ignoresSafeArea()
                
                VStack {
                    Rectangle()
                        .aspectRatio(18/29, contentMode: .fit)
                    
                    Spacer()
                    
                    Text("Scan food labels instantly and check if they're safe for you")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink {
                        PreferenceView()
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
                .padding()
            }
            .toolbarVisibility(.hidden)
        }
    }
}
