//
//  DataScannerView.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import AVKit
import SwiftUI
import Combine

struct CameraView: UIViewRepresentable {
    
    typealias UIViewType = CameraUIView
    
    func makeUIView(context: Context) -> UIViewType {
        .init()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

class CameraUIView: UIView, AVCapturePhotoCaptureDelegate {
    private let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?
    
    private var cancellables: [AnyCancellable] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCaptureSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        captureSession.sessionPreset = .photo
        
        do {
            guard let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) else {
                return
            }
            captureDevice = camera
            let input = try AVCaptureDeviceInput(device: camera)
            
            captureSession.addInput(input)
            captureSession.addOutput(photoOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = bounds
            self.layer.addSublayer(previewLayer)
            
            self.previewLayer = previewLayer
            
            self.startCapture()
            
            AppViewModel.shared.$shouldCapturePhoto
                .receive(on: DispatchQueue.main)
                .sink { value in
                    if value {
                        AppViewModel.shared.shouldCapturePhoto = false
                        self.capturePhoto()
                    }
                }
                .store(in: &cancellables)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.previewLayer?.frame = bounds
    }
    
    private func startCapture() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func capturePhoto() {
        photoOutput.capturePhoto(with: .init(), delegate: self)
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation(),
        let image = UIImage(data: imageData) else {
            assertionFailure()
            return
        }
        
        AppViewModel.shared.capturedPhoto = .init(image: image)
    }
}

struct IdentifiableImage: Identifiable, Hashable {
    let id = UUID()
    let image: UIImage
}
