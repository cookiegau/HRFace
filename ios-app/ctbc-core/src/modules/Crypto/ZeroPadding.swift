/// All the bytes that are required to be padded are padded with zero.
/// Zero padding may not be reversible if the original file ends with one or more zero bytes.
struct ZeroPadding: PaddingProtocol
{
	init()
	{
	}

	func add( to bytes: Array<UInt8>, blockSize: Int ) -> Array<UInt8>
	{
		let paddingCount = blockSize - ( bytes.count % blockSize )
		if paddingCount > 0
		{
			return bytes + Array<UInt8>( repeating: 0, count: paddingCount )
		}
		return bytes
	}

	func remove( from bytes: Array<UInt8>, blockSize _: Int? ) -> Array<UInt8>
	{
		for ( idx, value ) in bytes.reversed().enumerated()
		{
			if value != 0
			{
				return Array( bytes[0 ..< bytes.count - idx] )
			}
		}
		return bytes
	}
}
