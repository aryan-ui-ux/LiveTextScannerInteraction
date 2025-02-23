//
//  AppViewModel.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import AVKit
import PhotosUI
import SwiftUI

final class AppScannerViewModel: ObservableObject {
    
    enum AccessStatus {
        case notDetermined
        case denied
        case notAvailable
        case granted
    }
    
    static let shared: AppScannerViewModel = .init()

    @Published var accessStatus: AccessStatus = .notDetermined
    @Published var photo: IdentifiableImage? = nil
    @Published var capturePhoto: Bool = false
    
    init() {
        setup()
    }
    
    func setup() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            accessStatus = .notAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                accessStatus = .granted
            case .restricted, .denied:
                accessStatus = .denied
            case .notDetermined:
                accessStatus = .notDetermined
                Task {
                    await requestCameraAccess()
                }
            default:
                break
        }
    }
    
    @MainActor
    func requestCameraAccess() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        if granted {
            accessStatus = .granted
        } else {
            accessStatus = .denied
        }
    }
}
