struct NoPadding: PaddingProtocol
{
	init()
	{
	}

	func add( to data: Array<UInt8>, blockSize _: Int ) -> Array<UInt8>
	{
		data
	}

	func remove( from data: Array<UInt8>, blockSize _: Int? ) -> Array<UInt8>
	{
		data
	}
}
