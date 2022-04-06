import Foundation

extension Rabbit
{
	public convenience init( key: String ) throws
	{
		try self.init( key: key.bytes )
	}

	public convenience init( key: String, iv: String ) throws
	{
		try self.init( key: key.bytes, iv: iv.bytes )
	}
}
