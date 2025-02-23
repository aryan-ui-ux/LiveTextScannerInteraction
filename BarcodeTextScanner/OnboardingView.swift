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
                VStack {
                    LoopingVideoView()
                        .aspectRatio(18/29, contentMode: .fit)
                        .cornerRadius(24)
                        .accessibilityLabel("A looping animated video showing how to use the app.")
                    
                    Spacer()
                    
                    Text("Scan food labels instantly and check if they're safe for you")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink {
                        PreferenceView()
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(Color(.systemBackground))
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.label))
                            .clipShape(Capsule())
                    }
                    .accessibilityLabel("Next")
                    .accessibilityHint("Double tap to go to the next screen to select your dietary preference")
                    .accessibilityAddTraits(.isButton)
                }
                .padding()
            }
            .toolbarVisibility(.hidden)
        }
    }
}
