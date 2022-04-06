import Foundation
import UIKit



extension UIImageView
{
	public func setImageWithColor( _ tintColor: UIColor )
	{
		let size = self.frame.size
		self.image = UIImage( color: tintColor, size: size )
	}
}
