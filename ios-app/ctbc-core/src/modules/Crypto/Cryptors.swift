#if canImport( Darwin )
import Darwin
#else
import Glibc
#endif

/// Worker cryptor/decryptor of `Updatable` types
public protocol Cryptors: class
{

	/// Cryptor suitable for encryption
	func makeEncryptor() throws -> Cryptor & Updatable

	/// Cryptor suitable for decryption
	func makeDecryptor() throws -> Cryptor & Updatable

	/// Generate array of random bytes. Helper function.
	static func randomIV( _ blockSize: Int ) -> Array<UInt8>
}

extension Cryptors
{
	/// Generate array of random values.
	/// Convenience helper that uses `Swift.RandomNumberGenerator`.
	/// - Parameter count: Length of array
	public static func randomIV( _ count: Int ) -> Array<UInt8>
	{
		( 0 ..< count ).map( { _ in UInt8.random( in: 0 ... UInt8.max ) } )
	}
}
