public enum CipherError: Error
{
	case encrypt
	case decrypt
}

public protocol Cipher: AnyObject
{
	var keySize: Int { get }

	/// Encrypt given bytes at once
	///
	/// - parameter bytes: Plaintext data
	/// - returns: Encrypted data
	func encrypt( _ bytes: ArraySlice<UInt8> ) throws -> Array<UInt8>
	func encrypt( _ bytes: Array<UInt8> ) throws -> Array<UInt8>

	/// Decrypt given bytes at once
	///
	/// - parameter bytes: Ciphertext data
	/// - returns: Plaintext data
	func decrypt( _ bytes: ArraySlice<UInt8> ) throws -> Array<UInt8>
	func decrypt( _ bytes: Array<UInt8> ) throws -> Array<UInt8>
}

extension Cipher
{
	public func encrypt( _ bytes: Array<UInt8> ) throws -> Array<UInt8>
	{
		try self.encrypt( bytes.slice )
	}

	public func decrypt( _ bytes: Array<UInt8> ) throws -> Array<UInt8>
	{
		try self.decrypt( bytes.slice )
	}
}
