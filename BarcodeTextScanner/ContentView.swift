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
        switch vm.dataScannerAccessStatus {
            case .scannerAvailable:
                mainView
            case .cameraNotAvailable:
                Text("Your device doesn't have a camera")
            case .scannerNotAvailable:
                Text("Your device doesn't have support for scanning barcode with this app")
            case .cameraAccessNotGranted:
                Text("Please provide access to the camera in settings")
            case .notDetermined:
                Text("Requesting camera access")
        }
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
            Task { @MainActor in
                let decoder = LiveTextDecoder(image: capturedPhoto.image)
                let ingredients = await decoder.analyse()
                self.result = .init(ingredients: ingredients)
            }
        }
        .fullScreenCover(item: $result) { result in
            SafeView(ingredients: result.ingredients)
        }
    }
}
