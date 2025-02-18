//
//  DataScannerView.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import Foundation
import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var shouldCapturePhoto: Bool
    @Binding var capturedPhoto: IdentifiableImage?
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Only start scanning if not already scanning
        if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        }
        
        // Handle photo capture
        if shouldCapturePhoto {
            capturePhoto(dataScannerVC: uiViewController)
        }
    }
    
    private func capturePhoto(dataScannerVC: DataScannerViewController) {
        Task { @MainActor in
            do {
                dataScannerVC.stopScanning()  // Stop scanning before capture
                let photo = try await dataScannerVC.capturePhoto()
                self.capturedPhoto = .init(image: photo)
                try? dataScannerVC.startScanning()  // Resume scanning after capture
            } catch {
                print(error.localizedDescription)
            }
            self.shouldCapturePhoto = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        if uiViewController.isScanning {
            uiViewController.stopScanning()
        }
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: [RecognizedItem]

        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            print("didAddItems \(addedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: {$0.id == item.id })
            }
            print("didRemovedItems \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
        
    }
    
}

struct IdentifiableImage: Identifiable, Hashable {
    let id = UUID()
    let image: UIImage
}
