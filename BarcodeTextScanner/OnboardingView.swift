//
//  OnboardingView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 17/02/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let contentMode: UIView.ContentMode
    let animationSpeed: Double
    
    init(name: String, loopMode: LottieLoopMode = .loop, contentMode: UIView.ContentMode = .scaleAspectFit, animationSpeed: Double = 3.0) {
        self.animationName = name
        self.loopMode = loopMode
        self.contentMode = contentMode
        self.animationSpeed = animationSpeed
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        
        if let animation = LottieAnimation.named(animationName) {
            animationView.animation = animation
            animationView.contentMode = contentMode
            animationView.loopMode = loopMode
            animationView.animationSpeed = animationSpeed
            animationView.play()
            
            animationView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(animationView)
            
            NSLayoutConstraint.activate([
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    LoopingVideoView()
                        .aspectRatio(18/29, contentMode: .fit)
                        .cornerRadius(24)
                    
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
                }
                .padding()
            }
            .toolbarVisibility(.hidden)
        }
    }
}
