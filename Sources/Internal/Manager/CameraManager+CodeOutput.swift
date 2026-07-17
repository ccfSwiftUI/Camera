//
//  CameraManager+CodeOutput.swift of MijickCamera
//

@preconcurrency import AVFoundation
import UIKit

struct CameraScannedCode: Equatable {
    let value: String
    let type: AVMetadataObject.ObjectType
    let image: UIImage?

    init(value: String, type: AVMetadataObject.ObjectType, image: UIImage? = nil) {
        self.value = value
        self.type = type
        self.image = image
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value && lhs.type == rhs.type
    }
}

@MainActor final class CameraManagerCodeOutput: NSObject {
    private(set) weak var parent: CameraManager?
    private let output = AVCaptureMetadataOutput()
    private var mostRecentCode: CameraScannedCode?
}

extension CameraManagerCodeOutput {
    var rectOfInterest: CGRect { output.rectOfInterest }

    func setup(parent: CameraManager, types: [AVMetadataObject.ObjectType]) throws(MCameraError) {
        guard !types.isEmpty else { return }

        self.parent = parent
        try parent.captureSession.add(output: output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = types.filter(output.availableMetadataObjectTypes.contains)
        output.rectOfInterest = parent.attributes.codeScanningRect ?? .init(x: 0, y: 0, width: 1, height: 1)
    }

    func setRectOfInterest(_ rect: CGRect?) {
        output.rectOfInterest = rect ?? .init(x: 0, y: 0, width: 1, height: 1)
    }

    func reset() {
        parent = nil
        mostRecentCode = nil
    }
}

extension CameraManagerCodeOutput: @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let code = metadataObjects
            .compactMap({ $0 as? AVMetadataMachineReadableCodeObject })
            .compactMap({ object in object.stringValue.map { CameraScannedCode(value: $0, type: object.type) } })
            .first
        else { return }

        guard mostRecentCode != code else { return }
        mostRecentCode = code

        if parent?.attributes.capturesImageOnCodeScan == true {
            parent?.captureScannedCodeImage(for: code)
        } else {
            parent?.setScannedCode(code)
        }
    }
}
