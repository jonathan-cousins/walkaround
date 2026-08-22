#if canImport(UIKit)
import AVFoundation
import UIKit
import SwiftUI

// UIKit camera view controller for low-latency preview and capture
public class CameraCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isCameraAvailable: Bool = false
    
    public var onPhotoCaptured: ((UIImage) -> Void)?
    public var flashEnabled: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            isCameraAvailable = false
            setupSimulatorPreview()
            return
        }
        
        if captureSession.canAddInput(input) { captureSession.addInput(input) }
        if captureSession.canAddOutput(photoOutput) { captureSession.addOutput(photoOutput) }
        isCameraAvailable = true
        
        let pLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        pLayer.videoGravity = .resizeAspectFill
        pLayer.frame = view.bounds
        view.layer.insertSublayer(pLayer, at: 0)
        self.previewLayer = pLayer
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func setupSimulatorPreview() {
        // Subtle simulated viewfinder background for simulator/testing
        let simBackground = UIView(frame: view.bounds)
        simBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        simBackground.backgroundColor = UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1.0)
        view.insertSubview(simBackground, at: 0)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    public func capturePhoto() {
        if isCameraAvailable && captureSession.isRunning {
            let settings = AVCapturePhotoSettings()
            if let device = AVCaptureDevice.default(for: .video), device.hasFlash {
                settings.flashMode = flashEnabled ? .on : .off
            }
            photoOutput.capturePhoto(with: settings, delegate: self)
        } else {
            // Simulator or test environment: generate a crisp simulated vehicle photo
            let simPhoto = generateSimulatedInspectionPhoto()
            DispatchQueue.main.async { [weak self] in
                self?.onPhotoCaptured?(simPhoto)
            }
        }
    }
    
    private func generateSimulatedInspectionPhoto() -> UIImage {
        let size = CGSize(width: 1920, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            // Dark automotive tarmac backdrop
            let colors = [
                UIColor(red: 0.14, green: 0.16, blue: 0.20, alpha: 1.0).cgColor,
                UIColor(red: 0.06, green: 0.07, blue: 0.09, alpha: 1.0).cgColor
            ] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
                ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
            
            // Grid guides
            ctx.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.12).cgColor)
            ctx.cgContext.setLineWidth(2.0)
            ctx.cgContext.stroke(CGRect(x: 80, y: 80, width: size.width - 160, height: size.height - 160))
            
            // Central Alignment Target
            ctx.cgContext.move(to: CGPoint(x: size.width / 2, y: size.height / 2 - 30))
            ctx.cgContext.addLine(to: CGPoint(x: size.width / 2, y: size.height / 2 + 30))
            ctx.cgContext.move(to: CGPoint(x: size.width / 2 - 30, y: size.height / 2))
            ctx.cgContext.addLine(to: CGPoint(x: size.width / 2 + 30, y: size.height / 2))
            ctx.cgContext.strokePath()
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.onPhotoCaptured?(image)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isCameraAvailable {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
}

// SwiftUI wrapper
public struct CameraPreviewView: UIViewControllerRepresentable {
    public let flashEnabled: Bool
    public let onPhotoCaptured: (UIImage) -> Void
    @Binding public var captureController: CameraCaptureViewController?
    
    public init(
        flashEnabled: Bool,
        onPhotoCaptured: @escaping (UIImage) -> Void,
        captureController: Binding<CameraCaptureViewController?>
    ) {
        self.flashEnabled = flashEnabled
        self.onPhotoCaptured = onPhotoCaptured
        self._captureController = captureController
    }
    
    public func makeUIViewController(context: Context) -> CameraCaptureViewController {
        let vc = CameraCaptureViewController()
        vc.onPhotoCaptured = onPhotoCaptured
        vc.flashEnabled = flashEnabled
        DispatchQueue.main.async {
            captureController = vc
        }
        return vc
    }
    
    public func updateUIViewController(_ vc: CameraCaptureViewController, context: Context) {
        vc.flashEnabled = flashEnabled
        vc.onPhotoCaptured = onPhotoCaptured
    }
}
#endif
