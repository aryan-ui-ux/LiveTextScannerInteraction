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
struct LiveTextDecoder {
    let image: UIImage
    
    func analyse() async -> [String] {
        // Configure for high accuracy
        let analyzer = ImageAnalyzer()
        let interaction = ImageAnalysisInteraction()
        let configuration = ImageAnalyzer.Configuration([.text])
        
        do {
            let analysis = try await analyzer.analyze(image, configuration: configuration)
            
            // Validate analysis results
            guard !analysis.transcript.isEmpty else {
                return []
            }
            
            interaction.analysis = analysis
            interaction.preferredInteractionTypes = .automatic
            
            // Tokenize the text
            let tokens = analysis.transcript
                .components(separatedBy: CharacterSet(charactersIn: ",\n"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            return tokens
            
        } catch {
            return []
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

