//
//  LiveTextView.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 15/07/22.
//

import SwiftUI
import VisionKit
import Vision
import NaturalLanguage

extension UIImage {
    
    func extractText(completion: @escaping (_ languageCode: String?, _ text: String?) -> Void) {
        guard let cgImage = cgImage else {
            completion(nil, nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion(nil, nil)
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
            
            let tagger = NLTagger(tagSchemes: [.language])
            tagger.string = fullText
            
            let languageCode = tagger.dominantLanguage?.rawValue
            completion(languageCode, fullText)
        }
        
        // Configure the request for best accuracy.
        request.recognitionLevel = .accurate
        
        // Perform the request.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                completion(nil, nil)
            }
        }
    }
}
