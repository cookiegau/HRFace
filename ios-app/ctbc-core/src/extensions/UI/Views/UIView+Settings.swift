import Foundation
import UIKit

extension UIView
{
	public func setBorderBy( _ color: UIColor, _ width: CGFloat )
	{
		self.layer.borderColor = color.cgColor
		self.layer.borderWidth = width
	}
	public func setShadowBy( _ color: UIColor, _ opacity: Float = 0.5 )
	{
		self.layer.shadowColor = color.cgColor
		self.layer.shadowOpacity = opacity
	}
}
