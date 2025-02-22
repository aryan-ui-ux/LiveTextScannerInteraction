//
//  ContentView.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import PhotosUI
import SwiftUI
import VisionKit
import Translation

struct ContentView: View {
    
    struct ScanResult: Identifiable {
        let id: UUID = .init()
        let ingredients: [String]
    }
    
    @EnvironmentObject var vm: AppViewModel
    @State private var extractedText: String = ""
    @State private var result: ScanResult? = nil
    
    @State private var configuration: TranslationSession.Configuration?
    
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
            
            capturedPhoto.image.extractText { languageCode, text in
                self.extractedText = text ?? ""
                if let languageCode, languageCode != "en" {
                    self.configuration = .init(source: .init(identifier: languageCode), target: .init(languageCode: .english))
                } else {
                    getResult(text: text ?? "")
                }
            }
        }
        .translationTask(configuration) { session in
            do {
                let response = try await session.translate(extractedText)
                getResult(text: response.targetText)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        .onAppear {
            vm.capturedPhoto = .init(image: .init(named: "test2")!)
        }
        .fullScreenCover(item: $result) { result in
            SafeView(ingredients: result.ingredients)
        }
    }
    
    func getResult(text: String) {
        var paragraphs = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        
        if let index = paragraphs.firstIndex(where: { $0.localizedCaseInsensitiveContains("ingredient") }) {
            paragraphs.removeFirst(index)
            // We need to add common next section words becasue "." can also be used for numeric value. This is more deterministic.
            if let endIndex = paragraphs.firstIndex(where: { $0.contains("Nutritional") || $0.contains("Distributed") || $0.contains("EXPIRY")
            })  {
                    paragraphs = Array(paragraphs.prefix(endIndex + 1))
            } else if let postEndIndex = paragraphs.firstIndex(where: { !$0.contains(",") }) {
                // Edge case: If it can't find any next section starting words use all the words.
                if postEndIndex != 0 {
                    paragraphs = Array(paragraphs.prefix(postEndIndex))
                }
            }
        }

        
        let ingredients = paragraphs
            .joined(separator: " ")
            .replacingOccurrences(of: ".", with: ",")
            .replacingOccurrences(of: "  ", with: " ")
            .components(separatedBy: ",")
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: .punctuationCharacters)
            }
            .filter { !$0.isEmpty }
        
        self.result = .init(ingredients: ingredients)
    }
}
