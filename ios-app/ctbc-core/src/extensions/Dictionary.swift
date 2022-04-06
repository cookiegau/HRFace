import Foundation

extension Dictionary where Key == String, Value == Any
{
	public var toJson: String?
	{
		if let dict = ( self as AnyObject ) as? Dictionary<String, AnyObject>
		{
			do
			{
				let data = try JSONSerialization.data( withJSONObject: dict )
				if let string = String( data: data, encoding: String.Encoding.utf8 )
				{
					return string
				}
			}
			catch
			{
				print( error )
			}
		}
		return nil
	}

	public func findBy( _ name: String ) -> String?
	{
		if let s = self[ name ] as? String
		{
			return s
		}
		return nil
	}

	public func findBy( _ name: String, _ defaultValue: String ) -> String
	{
		if let s = self[ name ] as? String
		{
			return s
		}
		return defaultValue
	}

	public func findIntBy( _ name: String, _ defaultValue: Int ) -> Int
	{
		if let s = self[ name ] as? String
		{
			if let getVar = Int( s ) { return getVar }
		}
		return defaultValue
	}
	
	public func findBoolBy( _ name: String, _ defaultValue: Bool ) -> Bool
	{
		if let bool = self[ name ] as? Bool
		{
			return bool
		}
		return defaultValue
	}
}
