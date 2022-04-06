import UIKit

extension UIColor
{
	convenience init( red: Int, green: Int, blue: Int )
	{
		assert( red >= 0 && red <= 255, "Invalid red component" )
		assert( green >= 0 && green <= 255, "Invalid green component" )
		assert( blue >= 0 && blue <= 255, "Invalid blue component" )

		self.init( red: CGFloat( red ) / 255.0, green: CGFloat( green ) / 255.0, blue: CGFloat( blue ) / 255.0, alpha: 1.0 )
	}

	convenience init( hex: Int )
	{
		self.init(
				red: ( hex >> 16 ) & 0xFF,
				green: ( hex >> 8 ) & 0xFF,
				blue: hex & 0xFF
		)
	}

	convenience init( hex: Int, alpha: CGFloat )
	{
		self.init(
				red: CGFloat( ( hex >> 16 ) & 0xFF ),
				green: CGFloat( ( hex >> 8 ) & 0xFF ),
				blue: CGFloat( hex & 0xFF ),
				alpha: alpha
		)
	}

	convenience init( argbHex: Int )
	{
		self.init(
				red: CGFloat( ( argbHex >> 16 ) & 0xFF ),
				green: CGFloat( ( argbHex >> 8 ) & 0xFF ),
				blue: CGFloat( argbHex & 0xFF ),
				alpha: CGFloat( ( argbHex >> 24 ) & 0xFF )
		)
	}
}
