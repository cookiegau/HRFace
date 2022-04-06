import Foundation

extension HMAC
{
	public convenience init( key: String, variant: HMAC.Variant = .md5 ) throws
	{
		self.init( key: key.bytes, variant: variant )
	}
}
