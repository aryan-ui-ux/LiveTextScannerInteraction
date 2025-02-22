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




extension UIImage {
    
    func extractIngredients(completion: @escaping ([String]) -> Void) {
        guard let cgImage = cgImage else {
            completion([])
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion([])
                return
            }
            
            var fullText = ""
            if let observations = request.results as? [VNRecognizedTextObservation] {
                for observation in observations {
                    if let candidate = observation.topCandidates(1).first {
                        fullText += candidate.string + "\n"
                    }
                }
            }
            
            var paragraphs = fullText
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            
            if let index = paragraphs.firstIndex(where: { $0.localizedCaseInsensitiveContains("ingredient") }) {
                paragraphs.removeFirst(index)
                if let endIndex = paragraphs.firstIndex(where: { $0.contains(".") }) {
                    paragraphs = Array(paragraphs.prefix(endIndex + 1))
                } else if let postEndIndex = paragraphs.firstIndex(where: { !$0.contains(",") }) {
                    paragraphs = Array(paragraphs.prefix(postEndIndex))
                }
            }
            
            let ingredients = paragraphs
                .joined(separator: " ")
                .replacingOccurrences(of: ".", with: ",")
                .replacingOccurrences(of: "  ", with: " ")
                .components(separatedBy: ",")
                .map {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
                }
            
            completion(ingredients)
        }
        
        // Configure the request for best accuracy.
        request.recognitionLevel = .accurate
        
        // Perform the request.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                completion([])
            }
        }
    }
}
