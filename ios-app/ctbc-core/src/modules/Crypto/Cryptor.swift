/// Cryptor (Encryptor or Decryptor)
public protocol Cryptor
{
	/// Seek to position in file, if block mode allows random access.
	///
	/// - parameter to: new value of counter
	mutating func seek( to: Int ) throws
}
