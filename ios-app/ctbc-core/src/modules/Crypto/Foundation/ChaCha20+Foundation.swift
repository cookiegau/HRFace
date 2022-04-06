import Foundation

extension ChaCha20
{
	public convenience init( key: String, iv: String ) throws
	{
		try self.init( key: key.bytes, iv: iv.bytes )
	}
}
