import UIKit
import SwiftUI

//============================================================================================================
extension UILabel
{
	public func setOutlineTextBy( _ string: String, _ color: UIColor, _ width: CGFloat )
	{
		let attrStr = NSAttributedString(
				string: string,
				attributes:
				[
					NSAttributedString.Key.strokeColor: color,
					NSAttributedString.Key.strokeWidth: width,
					NSAttributedString.Key.foregroundColor: self.textColor,
					NSAttributedString.Key.font: self.font,
				]
		)

		self.attributedText = attrStr
	}
}
