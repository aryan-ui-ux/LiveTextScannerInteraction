//
//  LottieView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 22/02/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        
        if let animation = LottieAnimation.named(name) {
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = .loop
            animationView.animationSpeed = 1
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
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
