import UIKit

public extension UIImage
{
	func clone() -> UIImage
	{
		let cgi = self.cgImage!
		let scale = self.scale
		let ori = self.imageOrientation

		return UIImage( cgImage: cgi, scale: scale, orientation: ori )
	}

	func cropBy( _ rect: CGRect, _ orientation: UIImage.Orientation? = nil ) -> UIImage
	{
		let cgimage = self.cgImage!


		var setOrientation = self.imageOrientation
		if let newOrientation = orientation { setOrientation = newOrientation }

		let imageRef: CGImage = cgimage.cropping( to: rect )!
		let image: UIImage = UIImage( cgImage: imageRef, scale: self.scale, orientation: setOrientation )

		return image
	}

	func cropToBounds( image: UIImage, width: Double, height: Double ) -> UIImage
	{
		let cgimage = image.cgImage!
		let contextImage: UIImage = UIImage( cgImage: cgimage )
		let contextSize: CGSize = contextImage.size
		var posX: CGFloat = 0.0
		var posY: CGFloat = 0.0
		var cgwidth: CGFloat = CGFloat( width )
		var cgheight: CGFloat = CGFloat( height )

		if contextSize.width > contextSize.height
		{
			posX = ( ( contextSize.width - contextSize.height ) / 2 )
			posY = 0
			cgwidth = contextSize.height
			cgheight = contextSize.height
		}
		else
		{
			posX = 0
			posY = ( ( contextSize.height - contextSize.width ) / 2 )
			cgwidth = contextSize.width
			cgheight = contextSize.width
		}

		let rect: CGRect = CGRect( x: posX, y: posY, width: cgwidth, height: cgheight )
		return image.cropBy( rect )
	}
}

extension UIImage
{
	public convenience init?( color: UIColor, size: CGSize = CGSize( width: 1, height: 1 ) )
	{
		let rect = CGRect( origin: .zero, size: size )
		UIGraphicsBeginImageContextWithOptions( rect.size, false, 0.0 )
		color.setFill()
		UIRectFill( rect )
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		guard let cgImage = image?.cgImage else { return nil }
		self.init( cgImage: cgImage )
	}
}
