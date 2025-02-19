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

@MainActor
struct LiveTextDecoder {
    let image: UIImage
    private let ingredientStore = IngredientStore.shared
    
    private func cleanRawText(_ text: String) -> String {
        let commonPrefixes = [
            "ingredients:",
            "ingredients",
            "contains:",
            "contains",
            "made with:",
            "made with",
            "made from:",
            "made from",
            "composition:",
            "composition",
            "allergen information:",
            "allergen advice:",
            "allergy advice:"
        ]
        
        var cleanedText = text
        
        // Find the earliest occurrence of any prefix
        var earliestRange: Range<String.Index>?
        var earliestPrefix = ""
        
        for prefix in commonPrefixes {
            if let range = cleanedText.range(of: prefix, options: .caseInsensitive) {
                if earliestRange == nil || range.lowerBound < earliestRange!.lowerBound {
                    earliestRange = range
                    earliestPrefix = prefix
                }
            }
        }
        
        // If we found a prefix, remove everything before and including it
        if let range = earliestRange {
            cleanedText = String(text[range.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Remove common suffixes and their content
        let suffixPatterns = [
            "may contain traces of.*$",
            "manufactured in.*$",
            "produced in.*$",
            "for allergens.*$",
            "allergen information.*$",
            "nutrition information.*$",
            "nutritional information.*$",
            "storage:.*$",
            "store in.*$",
            "best before.*$",
            "use by.*$",
            "packed in.*$",
            "produced for.*$",
            "distributed by.*$"
        ]
        
        for pattern in suffixPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(cleanedText.startIndex..., in: cleanedText)
                cleanedText = regex.stringByReplacingMatches(
                    in: cleanedText,
                    options: [],
                    range: range,
                    withTemplate: ""
                )
            }
        }
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func tokenizeIngredients(_ text: String) -> [String] {
        print("\n=== Starting Tokenization ===")
        print("Raw text: \(text)")
        
        // First split by common list separators
        let initialTokens = text.components(separatedBy: CharacterSet(charactersIn: ".,;"))
        print("After initial split: \(initialTokens)")
            
        let processedTokens = initialTokens.flatMap { token -> [String] in
            // Further split by parentheses and brackets, preserving content inside
            let withoutParens = token.components(separatedBy: CharacterSet(charactersIn: "()[]"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            print("After parentheses split for '\(token)': \(withoutParens)")
            
            // Split compound ingredients
            return withoutParens.flatMap { part -> [String] in
                let compounds = part.components(separatedBy: " and ")
                    .flatMap { $0.components(separatedBy: " & ") }
                    .flatMap { $0.components(separatedBy: " with ") }
                    .map { cleanIngredient($0) }
                    .filter { !$0.isEmpty }
                print("After compound split for '\(part)': \(compounds)")
                return compounds
            }
        }
        
        print("Final tokens: \(processedTokens)")
        return processedTokens
    }
    
    private func cleanIngredient(_ ingredient: String) -> String {
        print("\n=== Cleaning ingredient: \(ingredient) ===")
        var cleaned = ingredient
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " - ", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "•", with: "")
            .replacingOccurrences(of: "·", with: "")
            .replacingOccurrences(of: ":", with: "")
        print("After basic cleaning: \(cleaned)")
        
        // Remove percentage values
        cleaned = cleaned.replacingOccurrences(of: #"\s*\d+(\.\d+)?%"#, with: "", options: .regularExpression)
        print("After removing percentages: \(cleaned)")
        
        // Remove E-numbers at the end
        cleaned = cleaned.replacingOccurrences(of: #"\s*\(?E\d+[a-z]?\)?"#, with: "", options: .regularExpression)
        print("After removing E-numbers: \(cleaned)")
        
        // Remove common prefixes
        let prefixesToRemove = ["contains", "including", "with", "from", "contains:", "including:", "with:", "from:"]
        for prefix in prefixesToRemove {
            if cleaned.lowercased().hasPrefix(prefix.lowercased()) {
                cleaned = String(cleaned.dropFirst(prefix.count))
                print("Removed prefix '\(prefix)': \(cleaned)")
            }
        }
        
        // Remove common non-ingredient words
        let wordsToRemove = ["trace", "traces", "may", "contain", "and/or", "or"]
        for word in wordsToRemove {
            cleaned = cleaned.replacingOccurrences(of: "\\b\(word)\\b", with: "", options: .regularExpression)
        }
        
        let final = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        print("Final cleaned ingredient: '\(final)'")
        return final
    }
    
    func analyse() async -> (rawText: String, tokens: [String]) {
        print("\n=== Starting Analysis ===")
        // Configure for high accuracy
        let analyzer = ImageAnalyzer()
        let interaction = ImageAnalysisInteraction()
        let configuration = ImageAnalyzer.Configuration([.text])
        
        do {
            let analysis = try await analyzer.analyze(image, configuration: configuration)
            
            // Validate analysis results
            guard !analysis.transcript.isEmpty else {
                print("❌ Empty transcript")
                return ("", [])
            }
            
            print("📝 Raw transcript: \(analysis.transcript)")
            
            interaction.analysis = analysis
            interaction.preferredInteractionTypes = .automatic
            
            // Store the raw transcript and clean it
            let rawText = cleanRawText(analysis.transcript)
            print("🧹 Cleaned text: \(rawText)")
            
            // Tokenize the text using the new tokenizer
            let tokens = tokenizeIngredients(rawText)
            print("🔍 Initial tokens: \(tokens)")
            
            // Filter out common non-ingredient text patterns
            let filteredTokens = tokens.filter { token in
                let lowercased = token.lowercased()
                
                // Helper function to check if string matches regex pattern
                func matches(pattern: String, in text: String) -> Bool {
                    guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
                    let range = NSRange(text.startIndex..., in: text)
                    return regex.firstMatch(in: text, range: range) != nil
                }
                
                let shouldKeep = !lowercased.contains("www") &&
                       !lowercased.contains(".com") &&
                       !lowercased.contains("alamy") &&
                       !lowercased.contains("image") &&
                       !lowercased.contains("id") &&
                       !lowercased.contains("suitable for") &&
                       !lowercased.contains("vegetarian") &&
                       !lowercased.contains("vegan") &&
                       !matches(pattern: #"^\d+$"#, in: lowercased) &&
                       !matches(pattern: #"^e\d+$"#, in: lowercased) &&
                       !matches(pattern: #"^\d+(\.\d+)?%$"#, in: lowercased) &&
                       !matches(pattern: #"^[a-z]?\d+$"#, in: lowercased) &&
                       token.count > 1 // Filter out single characters
                
                if !shouldKeep {
                    print("❌ Filtered out token: \(token)")
                }
                return shouldKeep
            }
            print("🔍 After filtering: \(filteredTokens)")
            
            // Remove duplicates while preserving order
            var seen = Set<String>()
            let uniqueTokens = filteredTokens.filter { token in
                let lowercased = token.lowercased()
                let isNew = !seen.contains(lowercased)
                if !isNew {
                    print("🔄 Removed duplicate: \(token)")
                }
                seen.insert(lowercased)
                return isNew
            }
            
            print("✅ Final tokens: \(uniqueTokens)")
            return (rawText, uniqueTokens)
            
        } catch {
            print("❌ Analysis failed: \(error)")
            return ("", [])
        }
    }
}

struct TokenView: View {
    let token: String
    let classification: IngredientType
    let onSave: () -> Void
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(token)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text(classification.rawValue.capitalized)
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
        switch classification {
        case .vegan:
            return .green
        case .vegetarian:
            return .blue
        case .animal:
            return .red
        case .pescatarian:
            return .cyan
        case .eggetarian:
            return .orange
        case .both:
            return .yellow
        }
    }
}

class LiveTextImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        .zero
    }
}

struct RawTextView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Raw Scanned Text:")
                .font(.headline)
            
            ScrollView {
                Text(text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 200)
        }
        .padding()
    }
}

