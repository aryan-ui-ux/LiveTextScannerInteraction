//
//  ContentView.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import PhotosUI
import SwiftUI
import VisionKit

struct ContentView: View {
    
    struct ScanResult: Identifiable {
        let id: UUID = .init()
        let ingredients: [String]
    }
    
    @EnvironmentObject var vm: AppViewModel
    @State private var result: ScanResult? = nil
    
    var body: some View {
        mainView
    }
    
    @ViewBuilder
    private var mainView: some View {
        VStack(spacing: .zero) {
            DataScannerView(
                shouldCapturePhoto: $vm.shouldCapturePhoto,
                capturedPhoto: $vm.capturedPhoto,
                recognizedItems: $vm.recognizedItems,
                recognizedDataType: vm.recognizedDataType,
                recognizesMultipleItems: vm.recognizesMultipleItems
            )
            .clipShape(.rect(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
            
            Button {
                vm.shouldCapturePhoto = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.clear)
                        .strokeBorder(Color.white, lineWidth: 3.5)
                    
                    Circle()
                        .foregroundStyle(
                            .radialGradient(
                                colors: [.white, Color(white: 0.5)],
                                center: .center,
                                startRadius: -10,
                                endRadius: 35
                            )
                        )
                        .padding(8)
                }
                .frame(width: 70, height: 70)
            }
            .padding(.vertical, 36)
        }
        .ignoresSafeArea(edges: .top)
        .onChange(of: vm.capturedPhoto) { _, capturedPhoto in
            guard let capturedPhoto else {
                return
            }
            
            capturedPhoto.image.extractIngredients() { ingredients in                
                DispatchQueue.main.async {
                    self.result = .init(ingredients: ingredients)
                }
            }
        }
        .onAppear {
            vm.capturedPhoto = .init(image: .init(named: "test3")!)
        }
        .fullScreenCover(item: $result) { result in
            SafeView(ingredients: result.ingredients)
        }
    }
}
