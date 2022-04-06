import Foundation
import UIKit

@IBDesignable
class BaseView: UIView
{
    @IBInspectable var isInCircle: Bool = false {
        didSet {
            if isInCircle == false { return }
            self.layer.cornerRadius  = min(bounds.width, bounds.height) / 2
        }
    }
    
    @IBInspectable var radius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = radius
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup()
    {
        self.addObserver(self, forKeyPath: "bounds", options: [], context: nil)
    }
	
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            if isInCircle == true {
                self.layer.cornerRadius  = min(bounds.width, bounds.height) / 2
                
                self.layer.masksToBounds = true
            }
        }
    }
}
