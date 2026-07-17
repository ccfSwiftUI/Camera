//
//  CaptureDeviceInput+AVCaptureDeviceInput.swift of MijickCamera
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import AVKit
import AVFoundation

extension AVCaptureDeviceInput: CaptureDeviceInput {
    static func get(mediaType: AVMediaType, position: AVCaptureDevice.Position?, prefersAutoSwitchingCamera: Bool) -> Self? {
        let device = { switch mediaType {
            case .audio: AVCaptureDevice.default(for: .audio)
            case .video where position == .front: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            case .video where position == .back:
                prefersAutoSwitchingCamera ? preferredBackCodeScanningCamera() ?? AVCaptureDevice.default(for: .video) : AVCaptureDevice.default(for: .video)
            default: fatalError()
        }}()

        guard let device, let deviceInput = try? Self(device: device) else { return nil }
        return deviceInput
    }

    private static func preferredBackCodeScanningCamera() -> AVCaptureDevice? {
        let preferredTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: preferredTypes,
            mediaType: .video,
            position: .back
        )

        return preferredTypes.lazy.compactMap { preferredType in
            discoverySession.devices.first { $0.deviceType == preferredType }
        }.first
    }
}
