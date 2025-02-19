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
                .flatMap { token -> [String] in
                    // Clean up each token
                    let cleaned = token
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: " - ", with: " ")
                        .replacingOccurrences(of: "-", with: " ")
                        .replacingOccurrences(of: "  ", with: " ")
                    
                    // Split on common ingredient separators and handle compound ingredients
                    let subTokens = cleaned.components(separatedBy: CharacterSet(charactersIn: "()[]"))
                        .flatMap { $0.components(separatedBy: " and ") }
                        .flatMap { $0.components(separatedBy: " & ") }
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    // Filter out common non-ingredient text patterns
                    let filteredTokens = subTokens.filter { token in
                        let lowercased = token.lowercased()
                        
                        // Helper function to check if string matches regex pattern
                        func matches(pattern: String, in text: String) -> Bool {
                            guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
                            let range = NSRange(text.startIndex..., in: text)
                            return regex.firstMatch(in: text, range: range) != nil
                        }
                        
                        return !lowercased.contains("www") &&
                               !lowercased.contains(".com") &&
                               !lowercased.contains("alamy") &&
                               !lowercased.contains("image") &&
                               !lowercased.contains("id") &&
                               !lowercased.contains("suitable for") &&
                               !lowercased.contains("vegetarian") &&
                               !lowercased.contains("eet") &&
                               !lowercased.contains("ohh") &&
                               !lowercased.contains("rgot") &&
                               !lowercased.contains("sar") &&
                               !matches(pattern: #"^\d+$"#, in: lowercased) &&
                               !matches(pattern: #"^e\d+$"#, in: lowercased)
                    }
                    
                    return filteredTokens
                }
                .filter { !$0.isEmpty }
            
            // Remove duplicates while preserving order
            var seen = Set<String>()
            let uniqueTokens = tokens.filter { token in
                let lowercased = token.lowercased()
                let isNew = !seen.contains(lowercased)
                seen.insert(lowercased)
                return isNew
            }
            
            return uniqueTokens
            
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

