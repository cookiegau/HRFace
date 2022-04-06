@available( *, renamed: "Digest" )
public typealias Hash = Digest

/// Hash functions to calculate Digest.
public struct Digest
{
	/// Calculate MD5 Digest
	/// - parameter bytes: input message
	/// - returns: Digest bytes
	public static func md5( _ bytes: Array<UInt8> ) -> Array<UInt8>
	{
		MD5().calculate( for: bytes )
	}

	/// Calculate SHA1 Digest
	/// - parameter bytes: input message
	/// - returns: Digest bytes
	public static func sha1( _ bytes: Array<UInt8> ) -> Array<UInt8>
	{
		SHA1().calculate( for: bytes )
	}

	/// Calculate SHA2-224 Digest
	/// - parameter bytes: input message
	/// - returns: Digest bytes
	public static func sha224( _ bytes: Array<UInt8> ) -> Array<UInt8>
	{
		self.sha2( bytes, variant: .sha224 )
	}

	/// Calculate SHA2-256 Digest
	/// - parameter bytes: input message
	/// - returns: Digest bytes
	public static func sha256( _ bytes: Array<UInt8> ) -> Array<UInt8>
	{
		self.sha2( bytes, variant: .sha256 )
	}

	/// Calculate SHA2-384 Digest
	/// - parameter bytes: input message
	/// - returns: Digest bytes
	public static func sha384( _ bytes: Array<UInt8> ) -> Array<UInt8>
	{
		self.sha2( bytes, variant: .sha384 )
	}

	/// Calculate SHA2-512 Digest
	/// - parameter bytes: input message
	/// - returns: Digest bytes
	public static func sha512( _ bytes: Array<UInt8> ) -> Array<UInt8>
	{
		self.sha2( bytes, variant: .sha512 )
	}

	/// Calculate SHA2 Digest
	/// - parameter bytes: input message
	/// - parameter variant: SHA-2 variant
	/// - returns: Digest bytes
	public static func sha2( _ bytes: Array<UInt8>, variant: SHA2.Variant ) -> Array<UInt8>
	{
		SHA2( variant: variant ).calculate( for: bytes )
	}

	/// Calculate SHA3 Digest
	/// - parameter bytes: input message
	/// - parameter variant: SHA-3 variant
	/// - returns: Digest bytes
	public static func sha3( _ bytes: Array<UInt8>, variant: SHA3.Variant ) -> Array<UInt8>
	{
		SHA3( variant: variant ).calculate( for: bytes )
	}
}
