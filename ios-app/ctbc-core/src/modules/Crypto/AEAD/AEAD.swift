// https://www.iana.org/assignments/aead-parameters/aead-parameters.xhtml

/// Authenticated Encryption with Associated Data (AEAD)
public protocol AEAD
{
	static var kLen: Int { get } // key length
	static var ivRange: Range<Int> { get } // nonce length
}

extension AEAD
{
	static func calculateAuthenticationTag( authenticator: Authenticator, cipherText: Array<UInt8>, authenticationHeader: Array<UInt8> ) throws -> Array<UInt8>
	{
		let headerPadding = ( ( 16 - ( authenticationHeader.count & 0xf ) ) & 0xf )
		let cipherPadding = ( ( 16 - ( cipherText.count & 0xf ) ) & 0xf )

		var mac = authenticationHeader
		mac += Array<UInt8>( repeating: 0, count: headerPadding )
		mac += cipherText
		mac += Array<UInt8>( repeating: 0, count: cipherPadding )
		mac += UInt64( bigEndian: UInt64( authenticationHeader.count ) ).bytes()
		mac += UInt64( bigEndian: UInt64( cipherText.count ) ).bytes()

		return try authenticator.authenticate( mac )
	}
}
