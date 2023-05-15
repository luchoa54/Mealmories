import Foundation
import UIKit

class ProgressBar: UIProgressView{
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayerPath = UIBezierPath(roundedRect : bounds,cornerRadius: 4.0)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskLayerPath.cgPath
        maskLayer.frame = self.bounds
        layer.mask = maskLayer
    }
    
}
