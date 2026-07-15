//
//  CameraManager+CodeOutput.swift of MijickCamera
//

@preconcurrency import AVFoundation

struct CameraScannedCode: Equatable {
    let value: String
    let type: AVMetadataObject.ObjectType
}

@MainActor final class CameraManagerCodeOutput: NSObject {
    private(set) weak var parent: CameraManager?
    private let output = AVCaptureMetadataOutput()
}

extension CameraManagerCodeOutput {
    func setup(parent: CameraManager, types: [AVMetadataObject.ObjectType]) throws(MCameraError) {
        guard !types.isEmpty else { return }

        self.parent = parent
        try parent.captureSession.add(output: output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = types.filter(output.availableMetadataObjectTypes.contains)
    }

    func reset() {
        parent = nil
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

        parent?.setScannedCode(code)
    }
}
