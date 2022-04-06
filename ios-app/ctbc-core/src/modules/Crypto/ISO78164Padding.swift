import Foundation

// First byte is 0x80, rest is zero padding
// http://www.crypto-it.net/eng/theory/padding.html
// http://www.embedx.com/pdfs/ISO_STD_7816/info_isoiec7816-4%7Bed21.0%7Den.pdf
struct ISO78164Padding: PaddingProtocol
{
	init()
	{
	}

	func add( to bytes: Array<UInt8>, blockSize: Int ) -> Array<UInt8>
	{
		var padded = Array( bytes )
		padded.append( 0x80 )

		while ( padded.count % blockSize ) != 0
		{
			padded.append( 0x00 )
		}
		return padded
	}

	func remove( from bytes: Array<UInt8>, blockSize _: Int? ) -> Array<UInt8>
	{
		if let idx = bytes.lastIndex( of: 0x80 )
		{
			return Array( bytes[..<idx] )
		}
		else
		{
			return bytes
		}
	}
}
