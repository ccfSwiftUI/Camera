//
//  CameraView+CodeScanningDebug.swift of MijickCamera
//

import UIKit

#if DEBUG
/// Debug-only visualisation of `AVCaptureMetadataOutput.rectOfInterest`.
final class CameraCodeScanningDebugView: UIView {
    private let borderLayer = CAShapeLayer()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear

        borderLayer.strokeColor = UIColor.systemRed.cgColor
        borderLayer.fillColor = UIColor.systemRed.withAlphaComponent(0.08).cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineDashPattern = [6, 4]
        layer.addSublayer(borderLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(parent: CameraManager) {
        addToParent(parent.cameraView)
    }

    func update(frame: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: frame, cornerRadius: 18).cgPath
        CATransaction.commit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
    }
}
#endif
