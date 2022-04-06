import Foundation

extension String
{
	public var base64: String
	{
		guard let d = data( using: .utf8 ) else { return "" }

		return d.base64EncodedString()
	}

	public var base64Decoded: String?
	{
		guard let data = Data( base64Encoded: self ) else { return nil }
		return String( data: data, encoding: .utf8 )
	}
}

public extension String
{
	var nsstring: NSString { get { return ( self as NSString ) } }

	var lastPath: String { get { return ( self as NSString ).lastPathComponent } }
	var pathExtension: String { get { return ( self as NSString ).pathExtension } }
	var stringByDeletingLastPath: String { get { return ( self as NSString ).deletingLastPathComponent } }
	var stringByDeletingPathExtension: String { get { return ( self as NSString ).deletingPathExtension } }
	var pathComponents: [String] { get { return ( self as NSString ).pathComponents } }

	var length: Int
	{
#if swift( >=3.2 )
		return count
#else
		return characters.count
#endif
	}

	var lengthOfBytes: Int
	{
		return self.lengthOfBytes( using: .ascii )
	}

	func stringByAppendingPathComponent( _ path: String ) -> String
	{
		let nsSt = self.nsstring
		return nsSt.appendingPathComponent( path )
	}

	func indexOf( _ target: String ) -> Int
	{
		if let range = self.range( of: target ) { return self.distance( from: self.startIndex, to: range.lowerBound ) }
		else { return -1 }
	}

	func replace( _ target: String, _ withString: String ) -> String
	{
		return self.replacingOccurrences( of: target, with: withString, options: NSString.CompareOptions.literal, range: nil )
	}

	subscript( r: Range<Int> ) -> String
	{
		get
		{
			let startIndex = self.index( self.startIndex, offsetBy: r.lowerBound )
			let endIndex = self.index( self.startIndex, offsetBy: r.upperBound )
			return String( self[( startIndex ..< endIndex )] )
		}
	}

	func SubStringBy( _ index: Int ) -> String
	{
		if ( self.count > index )
		{
			let startIndex = self.index( self.startIndex, offsetBy: index )
			let subString = self[startIndex ..< self.endIndex]

			return String( subString )
		}
		else
		{
			return self
		}
	}

	func SubStringBy( _ index: String.Index ) -> String
	{
		let str = self[index ..< self.endIndex];
		return String( str )
	}

	func SubStringBy( _ string: String ) -> String
	{
		let idx = self.range( of: string )?.lowerBound
		if ( idx == nil ) { return string; }
		else { return self.SubStringBy( idx! ); }
	}

	func IsContainAnyBy( _ items: Array<String> ) -> Bool
	{
		for chars in items { if ( self.contains( chars ) ) { return true; } }
		return false;
	}

	//==========================================================================================
	// Regex
	//==========================================================================================
	func regexMatchBy( _ regexStr: String ) -> Bool
	{
		let regex: NSRegularExpression?
		do { try regex = NSRegularExpression( pattern: regexStr, options: .caseInsensitive ) }
		catch { return false }

		if let matches = regex?.matches( in: self, options: NSRegularExpression.MatchingOptions( rawValue: 0 ), range: NSMakeRange( 0, self.count ) ) { return matches.count > 0 }
		else { return false }
	}

	func regexReplaceBy( _ regex: String, _ replacement: String ) -> String
	{
		let value = NSMutableString( string: self )

		let regex = try? NSRegularExpression( pattern: regex )
		regex?.replaceMatches( in: value, options: .reportProgress, range: NSRange( location: 0, length: value.length ), withTemplate: replacement )

		return value as String;
	}
}

