import Foundation

public class TimeRange: CustomStringConvertible
{
	public private(set) var intS: Int = 0
	public private(set) var intE: Int = 0

	init( _ s: String.SubSequence, _ e: String.SubSequence )
	{
		intS = Int( String( describing: s ).replace( ":", "" ) ) ?? 0
		intE = Int( String( describing: e ).replace( ":", "" ) ) ?? 0
	}

	public var description: String
	{
		return "{\( intS )-\( intE )}"
	}

	public func IsMatchBy( _ date: Date ) -> Bool
	{
		let nowHHmm = TimeRange.GetIntBy( date )
		return nowHHmm >= intS && nowHHmm <= intE
	}



	public static var fmtHM: DateFormatter =
	{
		let df = DateFormatter()
		df.dateFormat = "HHmm"
		return df
	}()

	public static func GetIntBy( _ date: Date ) -> Int
	{
		return Int( TimeRange.fmtHM.string( from: date ) ) ?? 0
	}

	public static func ParseBy( _ str: String ) -> [TimeRange]
	{
		let strs = str.replace( " ", "" ).split( separator: "," )

		var exFmts: [String] = []
		var ranges: [TimeRange] = []


		for s in strs
		{
			let pair = s.split( separator: "-" )
			if ( pair.count != 2 ) || ( pair[0].count <= 0 || pair[1].count <= 0 )
			{
				exFmts.append( String( describing: s ) )
			}
			else
			{
				let range = TimeRange( pair[0] , pair[1] )

				if( range.intS <= 0 || range.intE <= 0 )
				{
					exFmts.append( String( describing: s ) )
					continue
				}

				ranges.append( range )
			}
		}

		if( exFmts.count > 0 )
		{
			Log.Warn( "[TimeRange] setting Error for Values: \( exFmts )" )
		}

		return ranges
	}
}


extension Array where Element == TimeRange
{
	public func CheckNowInRange() -> Bool
	{
		let now = Date()
		let match = self.findInRangeBy( now )

		return match != nil
	}

	public func findInRangeBy( _ date: Date ) -> TimeRange?
	{
		return self.first{ $0.IsMatchBy( date ) }
	}
}
