import Foundation

extension URL
{
	public func normalize() -> URL
	{
		var str = self.absoluteString

		// 取代double slash
		str = str.regexReplaceBy( "(?<!http:)//", "/" )

		return URL( string: str )!
	}
}
