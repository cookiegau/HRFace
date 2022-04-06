import Foundation

public extension Array where Element == UInt8
{
	func toBase64() -> String?
	{
		Data( self ).base64EncodedString()
	}

	init( base64: String )
	{
		self.init()

		guard let decodedData = Data( base64Encoded: base64 ) else
		{
			return
		}

		append( contentsOf: decodedData.bytes )
	}
}
