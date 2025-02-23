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
    @State private var showDemoImagePicker: Bool = false
    
    @State private var configuration: TranslationSession.Configuration?
    
    @State private var selectedIndex: Int = 1
    
    var body: some View {
        VStack(spacing: .zero) {
            CameraView()
                .clipShape(.rect(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
            
            HStack {
                Spacer()
                
                Button {
                    vm.shouldCapturePhoto = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(.clear)
                            .strokeBorder(Color.white, lineWidth: 3.5)
                        
                        Circle()
                            .foregroundStyle(
                                .linearGradient(.init(colors: [
                                    .init(red: 159/255, green: 159/255, blue: 159/255),
                                    Color.white
                                ]), startPoint: .top, endPoint: .bottom)
                            )
                            .padding(8)
                    }
                    .frame(width: 70, height: 70)
                }
                .padding(.vertical, 36)
                
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button {
                    showDemoImagePicker = true
                } label: {
                    Image(systemName: "photo")
                        .imageScale(.large)
                        .foregroundStyle(.white)
                        .padding()
                }
            }
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
                print(error.localizedDescription)
                getResult(text: extractedText)
            }
        }
        .fullScreenCover(item: $result) { result in
            SafeView(ingredients: result.ingredients)
        }
        .sheet(isPresented: $showDemoImagePicker) {
            VStack {
                Text("Demo Data")
                    .font(.headline)
                    .fontWeight(.medium)
                    .padding(.top, 14)
                    .multilineTextAlignment(.center)
                
                TabView(selection: $selectedIndex) {
                    ForEach(1...5, id: \.self) { id in
                        Rectangle()
                            .foregroundStyle(.clear)
                            .overlay(alignment: .top) {
                                Image("test\(id)")
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipShape(.rect(cornerRadius: 24))
                            .padding(.bottom, 36)
                            .tag(id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .scrollContentBackground(.hidden)
                
                Button {
                    showDemoImagePicker = false
                    vm.capturedPhoto = .init(image: UIImage(named: "test\(selectedIndex)")!)
                } label: {
                    Text("Select")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
            }
        }
    }
    
    func getResult(text: String) {
        var paragraphs = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let lowercasedParagraphs = paragraphs.map { $0.lowercased() }
        
        if let index = lowercasedParagraphs.firstIndex(where: { $0.contains("ingredient") }) {
            paragraphs.removeFirst(index)
            // We need to add common next section words because "." can also be used for numeric value. This is more deterministic.
            if let endIndex = lowercasedParagraphs.firstIndex(where: { $0.contains("nutritional") || $0.contains("distributed") || $0.contains("expiry")
            })  {
                    paragraphs = Array(paragraphs.prefix(endIndex + 1))
            } else if let postEndIndex = lowercasedParagraphs.firstIndex(where: { !$0.contains(",") }) {
                // Edge case: If it can't find any next section starting words use all the words.
                if postEndIndex != 0 {
                    paragraphs = Array(paragraphs.prefix(postEndIndex))
                }
            }
        }

        print(paragraphs)
        
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

        print("ingredients: ", ingredients)
        
        self.result = .init(ingredients: ingredients)
    }
}
