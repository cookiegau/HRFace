import Foundation

extension Array where Element == Double
{
	public func toRawString() -> String
	{
		let idxLast = ( self.count - 1 )
		var str = ""
		for idx in 0 ... idxLast
		{
			let value = self[idx]
			str += "\( value )"

			if( idx != idxLast ) { str += "," }
		}

		return str
	}
}
