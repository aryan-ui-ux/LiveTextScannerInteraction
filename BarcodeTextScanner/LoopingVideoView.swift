//
//  LoopingVideoView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 22/02/25.
//

import AVKit
import SwiftUI

struct LoopingVideoView: View {
    let player: AVPlayer
    
    init() {
        let url = Bundle.main.url(forResource: "onboarding", withExtension: "mp4")!
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        self.player = player
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                    self.player.seek(to: .zero)
                    self.player.play()
                }
                
                player.play()
            }
            .onDisappear {
                player.pause()
            }
    }
}
