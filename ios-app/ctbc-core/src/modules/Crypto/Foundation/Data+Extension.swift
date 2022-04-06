import Foundation

extension Data
{
	/// Two octet checksum as defined in RFC-4880. Sum of all octets, mod 65536
	public func checksum() -> UInt16
	{
		let s = self.withUnsafeBytes
		{ buf in
			return buf.lazy.map( UInt32.init ).reduce( UInt32( 0 ), + )
		}
		return UInt16( s % 65535 )
	}

	public func md5() -> Data
	{
		Data( Digest.md5( bytes ) )
	}

	public func sha1() -> Data
	{
		Data( Digest.sha1( bytes ) )
	}

	public func sha224() -> Data
	{
		Data( Digest.sha224( bytes ) )
	}

	public func sha256() -> Data
	{
		Data( Digest.sha256( bytes ) )
	}

	public func sha384() -> Data
	{
		Data( Digest.sha384( bytes ) )
	}

	public func sha512() -> Data
	{
		Data( Digest.sha512( bytes ) )
	}

	public func sha3( _ variant: SHA3.Variant ) -> Data
	{
		Data( Digest.sha3( bytes, variant: variant ) )
	}

	public func crc32( seed: UInt32? = nil, reflect: Bool = true ) -> Data
	{
		Data( Checksum.crc32( bytes, seed: seed, reflect: reflect ).bytes() )
	}

	public func crc32c( seed: UInt32? = nil, reflect: Bool = true ) -> Data
	{
		Data( Checksum.crc32c( bytes, seed: seed, reflect: reflect ).bytes() )
	}

	public func crc16( seed: UInt16? = nil ) -> Data
	{
		Data( Checksum.crc16( bytes, seed: seed ).bytes() )
	}

	public func encrypt( cipher: Cipher ) throws -> Data
	{
		Data( try cipher.encrypt( bytes.slice ) )
	}

	public func decrypt( cipher: Cipher ) throws -> Data
	{
		Data( try cipher.decrypt( bytes.slice ) )
	}

	public func authenticate( with authenticator: Authenticator ) throws -> Data
	{
		Data( try authenticator.authenticate( bytes ) )
	}
}

extension Data
{
	public init( hex: String )
	{
		self.init( Array<UInt8>( hex: hex ) )
	}

	public var bytes: Array<UInt8>
	{
		Array( self )
	}

	public func toHexString() -> String
	{
		self.bytes.toHexString()
	}
}
