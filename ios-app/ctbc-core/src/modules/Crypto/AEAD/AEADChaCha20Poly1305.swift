//  https://tools.ietf.org/html/rfc7539#section-2.8.1

/// AEAD_CHACHA20_POLY1305
public final class AEADChaCha20Poly1305: AEAD
{
	public static let kLen = 32 // key length
	public static var ivRange = Range<Int>( 12 ... 12 )

	/// Authenticated encryption
	public static func encrypt( _ plainText: Array<UInt8>, key: Array<UInt8>, iv: Array<UInt8>, authenticationHeader: Array<UInt8> ) throws -> ( cipherText: Array<UInt8>, authenticationTag: Array<UInt8> )
	{
		let cipher = try ChaCha20( key: key, iv: iv )

		var polykey = Array<UInt8>( repeating: 0, count: kLen )
		var toEncrypt = polykey
		polykey = try cipher.encrypt( polykey )
		toEncrypt += polykey
		toEncrypt += plainText

		let fullCipherText = try cipher.encrypt( toEncrypt )
		let cipherText = Array( fullCipherText.dropFirst( 64 ) )

		let tag = try calculateAuthenticationTag( authenticator: Poly1305( key: polykey ), cipherText: cipherText, authenticationHeader: authenticationHeader )
		return ( cipherText, tag )
	}

	/// Authenticated decryption
	public static func decrypt( _ cipherText: Array<UInt8>, key: Array<UInt8>, iv: Array<UInt8>, authenticationHeader: Array<UInt8>, authenticationTag: Array<UInt8> ) throws -> ( plainText: Array<UInt8>, success: Bool )
	{
		let chacha = try ChaCha20( key: key, iv: iv )

		let polykey = try chacha.encrypt( Array<UInt8>( repeating: 0, count: self.kLen ) )
		let mac = try calculateAuthenticationTag( authenticator: Poly1305( key: polykey ), cipherText: cipherText, authenticationHeader: authenticationHeader )
		guard mac == authenticationTag else
		{
			return ( cipherText, false )
		}

		var toDecrypt = Array<UInt8>( reserveCapacity: cipherText.count + 64 )
		toDecrypt += polykey
		toDecrypt += polykey
		toDecrypt += cipherText
		let fullPlainText = try chacha.decrypt( toDecrypt )
		let plainText = Array( fullPlainText.dropFirst( 64 ) )
		return ( plainText, true )
	}
}
