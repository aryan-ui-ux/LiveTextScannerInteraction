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
    
    @EnvironmentObject var vm: AppScannerViewModel
    @State var extractedText: String = ""
    @State var result: ScanResult? = nil
    @State var showDemoImagePicker: Bool = false
    
    @State var configuration: TranslationSession.Configuration?
    
    @State var selectedIndex: Int = 1
    
    var body: some View {
        VStack(spacing: .zero) {
            CameraView()
                .clipShape(.rect(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
            
            HStack {
                Spacer()
                
                Button {
                    vm.capturePhoto = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(.clear)
                            .strokeBorder(Color.white, lineWidth: 3.5)
                        
                        Circle()
                            .foregroundStyle(.linearGradient(.init(colors: [.init(red: 159/255, green: 159/255, blue: 159/255), Color.white]), startPoint: .top, endPoint: .bottom))
                            .padding(8)
                    }
                    .frame(width: 70, height: 70)
                }
                .accessibilityLabel("Click image")
                .accessibilityHint("Double tap to click image to scan for ingredients")
                .accessibilityAddTraits(.isButton)
                .padding(.vertical, 36)
                
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button {
                    showDemoImagePicker = true
                } label: {
                    HStack(spacing: -12) {
                        Rectangle()
                            .overlay {
                                Image("test1")
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipShape(.rect(cornerRadius: 12))
                            .rotationEffect(.degrees(-13))
                            .frame(width: 36, height: 50)
                        
                        Rectangle()
                            .overlay {
                                Image("test2")
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.black, lineWidth: 3)
                            }
                            .rotationEffect(.degrees(6.5))
                            .frame(width: 44, height: 58)
                    }
                    .accessibilityLabel("Demo images")
                    .accessibilityHint("Double tap to go into a gallery for demo images")
                    .accessibilityAddTraits(.isButton)
                    .padding(.horizontal)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .onChange(of: vm.photo) { _, capturedPhoto in
            if let capturedPhoto {
                capturedPhoto.image.getText { languageCode, text in
                    self.extractedText = text ?? ""
                    if let languageCode, languageCode != "en" {
                        self.configuration = .init(source: .init(identifier: languageCode), target: .init(languageCode: .english))
                    } else {
                        getResult(text: text ?? "")
                    }
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
                .environment(\.colorScheme, .dark)
        }
        .sheet(isPresented: $showDemoImagePicker) {
            VStack {
                Text("Demo Data")
                    .font(.headline)
                    .fontWeight(.medium)
                    .padding(.top, 14)
                    .multilineTextAlignment(.center)
                
                TabView(selection: $selectedIndex) {
                    ForEach(1...2, id: \.self) { id in
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
                            .accessibilityLabel("Sample demo image \(id)")
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .scrollContentBackground(.hidden)
                
                Button {
                    showDemoImagePicker = false
                    vm.photo = .init(image: UIImage(named: "test\(selectedIndex)")!)
                } label: {
                    Text("Select")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .accessibilityLabel("Select")
                .accessibilityHint("Double tap to go select image as your demo image for testing")
                .accessibilityAddTraits(.isButton)
                .padding(.horizontal)
            }
            .environment(\.colorScheme, .dark)
        }
        .background {
            Color(uiColor: UIColor.systemBackground)
                .ignoresSafeArea()
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
            // Remove "ingredients:" or "ingredient:" from the first paragraph
            if !paragraphs.isEmpty {
                paragraphs[0] = paragraphs[0]
                    .replacingOccurrences(of: "Ingredients:", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "Ingredient:", with: "", options: .caseInsensitive)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
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
