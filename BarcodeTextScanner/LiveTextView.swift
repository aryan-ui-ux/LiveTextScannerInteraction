//
//  LiveTextView.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 15/07/22.
//

import Foundation
import SwiftUI
import VisionKit
import Vision
import CoreData
import Combine

// Simple ingredient classifier
final class IngredientClassifier: ObservableObject {
    static let shared = IngredientClassifier()
    
    @Published private(set) var classifications: [String: String] = [:]
    
    private init() {}
    
    func classifyIngredient(_ ingredient: String) -> String {
        if let existing = classifications[ingredient] {
            return existing
        }
        let possibleClassifications = ["veg", "non-veg", "vegan", "unknown"]
        let classification = possibleClassifications.randomElement()!
        classifications[ingredient] = classification
        objectWillChange.send()
        return classification
    }
}

@MainActor
struct LiveTextView: UIViewRepresentable {
    let image: UIImage
    @Binding var recognizedText: String
    @Binding var recognizedTokens: [String]
    @Binding var isProcessing: Bool
    let imageView = LiveTextImageView()
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    func makeUIView(context: Context) -> some UIView {
        imageView.image = image
        imageView.addInteraction(interaction)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let image = imageView.image else { return }
        Task { @MainActor in
            isProcessing = true
            
            // Configure for high accuracy
            let configuration = ImageAnalyzer.Configuration([.text])
            
            do {
                let analysis = try await analyzer.analyze(image, configuration: configuration)
                
                // Validate analysis results
                guard !analysis.transcript.isEmpty else {
                    recognizedText = "No text was detected in the image."
                    recognizedTokens = []
                    isProcessing = false
                    return
                }
                
                interaction.analysis = analysis
                interaction.preferredInteractionTypes = .automatic
                
                // Store the full text
                recognizedText = analysis.transcript
                
                // Tokenize the text
                let tokens = analysis.transcript
                    .components(separatedBy: CharacterSet(charactersIn: ",\n"))
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                recognizedTokens = tokens
                
            } catch {
                recognizedText = "Error analyzing image: \(error.localizedDescription)"
                recognizedTokens = []
            }
            isProcessing = false
        }
    }
}

struct LiveTextContainerView: View {
    let image: UIImage
    @State private var recognizedText: String = ""
    @State private var recognizedTokens: [String] = []
    @State private var showCopiedAlert: Bool = false
    @State private var isProcessing: Bool = false
    @State private var ingredientClassifications: [String: String] = [:]
    @State private var finalVerdict: String = ""
    @EnvironmentObject private var persistence: Persistence
    @StateObject private var classifier = IngredientClassifier.shared
    
    private func classifyIngredients() {
        ingredientClassifications = [:]
        Task { @MainActor in
            for token in recognizedTokens {
                ingredientClassifications[token] = classifier.classifyIngredient(token)
            }
            
            // Calculate final verdict
            let classifications = Set(ingredientClassifications.values)
            if classifications.contains("non-veg") {
                finalVerdict = "Non-Vegetarian"
            } else if classifications.contains("veg") && !classifications.contains("vegan") {
                finalVerdict = "Vegetarian"
            } else if classifications.contains("vegan") {
                finalVerdict = "Vegan"
            } else {
                finalVerdict = "Unknown"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            LiveTextView(image: image, 
                        recognizedText: $recognizedText,
                        recognizedTokens: $recognizedTokens,
                        isProcessing: $isProcessing)
                .frame(height: UIScreen.main.bounds.height * 0.4)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Recognized Items:")
                            .font(.headline)
                        
                        if isProcessing {
                            ProgressView()
                                .padding(.leading, 8)
                        }
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = recognizedText
                            showCopiedAlert = true
                            
                            // Hide the alert after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopiedAlert = false
                            }
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .imageScale(.large)
                        }
                        .disabled(recognizedText.isEmpty)
                        .overlay {
                            if showCopiedAlert {
                                Text("Copied!")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.75))
                                    .cornerRadius(6)
                                    .offset(y: 30)
                            }
                        }
                    }
                    
                    if recognizedTokens.isEmpty && !isProcessing {
                        Text("No items detected")
                            .foregroundColor(.gray)
                            .padding(.top)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(recognizedTokens, id: \.self) { token in
                                TokenView(token: token, classification: ingredientClassifications[token] ?? "unknown") {
                                    // Handle save action
                                }
                            }
                        }
                        .padding(.top)
                        
                        if !recognizedTokens.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Final Verdict:")
                                    .font(.headline)
                                    .padding(.top)
                                
                                Text(finalVerdict)
                                    .font(.title2)
                                    .foregroundColor(getFinalVerdictColor())
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(getFinalVerdictColor().opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onChange(of: recognizedTokens) { _ in
            classifyIngredients()
        }
    }
    
    private func getFinalVerdictColor() -> Color {
        switch finalVerdict {
        case "Vegan":
            return .green
        case "Vegetarian":
            return .blue
        case "Non-Vegetarian":
            return .red
        default:
            return .gray
        }
    }
}

struct TokenView: View {
    let token: String
    let classification: String
    let onSave: () -> Void
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(token)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text(classification.capitalized)
                .font(.caption)
                .foregroundColor(getClassificationColor())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(getClassificationColor().opacity(0.1))
        .cornerRadius(8)
        .overlay {
            if showingSaveConfirmation {
                Text("Saved!")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
                    .offset(y: 24)
            }
        }
    }
    
    private func getClassificationColor() -> Color {
        switch classification.lowercased() {
        case "vegan":
            return .green
        case "veg":
            return .blue
        case "non-veg":
            return .red
        default:
            return .gray
        }
    }
}

class LiveTextImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        .zero
    }
}

