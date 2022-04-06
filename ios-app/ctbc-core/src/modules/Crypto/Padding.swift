public protocol PaddingProtocol
{
	func add( to: Array<UInt8>, blockSize: Int ) -> Array<UInt8>
	func remove( from: Array<UInt8>, blockSize: Int? ) -> Array<UInt8>
}

public enum Padding: PaddingProtocol
{
	case noPadding, zeroPadding, pkcs7, pkcs5, iso78164

	public func add( to: Array<UInt8>, blockSize: Int ) -> Array<UInt8>
	{
		switch self
		{
			case .noPadding:
				return to // NoPadding().add(to: to, blockSize: blockSize)
			case .zeroPadding:
				return ZeroPadding().add( to: to, blockSize: blockSize )
			case .pkcs7:
				return PKCS7.Padding().add( to: to, blockSize: blockSize )
			case .pkcs5:
				return PKCS5.Padding().add( to: to, blockSize: blockSize )
			case .iso78164:
				return ISO78164Padding().add( to: to, blockSize: blockSize )
		}
	}

	public func remove( from: Array<UInt8>, blockSize: Int? ) -> Array<UInt8>
	{
		switch self
		{
			case .noPadding:
				return from //NoPadding().remove(from: from, blockSize: blockSize)
			case .zeroPadding:
				return ZeroPadding().remove( from: from, blockSize: blockSize )
			case .pkcs7:
				return PKCS7.Padding().remove( from: from, blockSize: blockSize )
			case .pkcs5:
				return PKCS5.Padding().remove( from: from, blockSize: blockSize )
			case .iso78164:
				return ISO78164Padding().remove( from: from, blockSize: blockSize )
		}
	}
}
