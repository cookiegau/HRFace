/// Message authentication code.
public protocol Authenticator
{
	/// Calculate Message Authentication Code (MAC) for message.
	func authenticate( _ bytes: Array<UInt8> ) throws -> Array<UInt8>
}
