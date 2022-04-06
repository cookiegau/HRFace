internal protocol DigestType
{
	func calculate( for bytes: Array<UInt8> ) -> Array<UInt8>
}
