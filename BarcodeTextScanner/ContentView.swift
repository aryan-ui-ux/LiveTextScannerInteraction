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
        let rawText: String
        let ingredients: [String]
        let classifiedIngredients: (
            whitelisted: [Ingredient],
            blacklisted: [Ingredient],
            vegan: [Ingredient],
            nonVegan: [Ingredient],
            unclassified: [Ingredient]
        )
    }
    
    @EnvironmentObject var vm: AppViewModel
    @State private var result: ScanResult? = nil
    private let ingredientStore = IngredientStore.shared
    
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
                let (rawText, ingredients) = await decoder.analyse()
                
                // Get user preference
                let preference = Preference(rawValue: UserDefaults.standard.string(forKey: "preference") ?? "") ?? .vegan
                
                // Classify ingredients
                let classifiedIngredients = ingredientStore.getIngredients(
                    from: ingredients,
                    for: preference
                )
                
                self.result = .init(
                    rawText: rawText,
                    ingredients: ingredients,
                    classifiedIngredients: classifiedIngredients
                )
            }
        }
        .fullScreenCover(item: $result) { result in
            VStack {
                RawTextView(text: result.rawText)
                SafeView(
                    ingredients: result.ingredients,
                    classifiedIngredients: result.classifiedIngredients
                )
            }
        }
    }
}
