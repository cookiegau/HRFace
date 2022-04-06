import Foundation

public class dbConfig
{
	private(set) var name: String
	private(set) var value: String

	init( _ json: Json )
	{
		name = json["configKey"].stringValue
		value = json["configValue"].stringValue
	}

	var valueInt: Int { get { return Int( value ) ?? 0 } }

	func getValueStrOr( _ defaultValue: String ) -> String
	{
		if value.length <= 0 { return defaultValue }
		return value
	}

	func getValueIntOr( _ defaultValue: Int ) -> Int { return Int( value ) ?? defaultValue }

	func getValueDoubleOr( _ defaultValue: Double ) -> Double { return Double( value ) ?? defaultValue }

	func getValueBoolOr( _ defaultValue: Bool ) -> Bool
	{
		if value.length <= 0 { return defaultValue }
		return value.lowercased() == "true"
	}

	public static func parseModelsBy( _ str: String, _ onlyKeepIOS: Bool = true ) -> [dbConfig]
	{
		var items: [dbConfig] = []

		let json = Json.parseBy( str )

		for ( _, itemJson ): ( String, Json ) in json
		{
			//print( "[config:item] \( itemJson )" )
			if let ex = itemJson.error
			{
				Log.Error( "[dbConfig] parseModel error[\( ex )] raw[\( itemJson.rawValue )]" )
			}
			else
			{
				let item = dbConfig( itemJson )

				if ( !onlyKeepIOS || item.name.lowercased().hasPrefix( "ios" ) ) { items.append( item ) }
			}
		}

		return items
	}
}

extension dbConfig: CustomStringConvertible
{
	public var description: String
	{
		return "{\( name )[\( value )]}"
	}
}

extension Array where Element == dbConfig
{
	public func findConfigBy( _ ip: String, _ name: String ) -> dbConfig?
	{
		var config = self.first
		{
			c in
			let configName = c.name.lowercased()
			return configName.hasSuffix( "ios:\( ip ):\( name )".lowercased() ) || configName.hasSuffix( "ios.sdk:\( ip ):\( name )".lowercased() )
		}
		if ( config == nil )
		{
			config = self.first
			{
				c in
				let configName = c.name.lowercased()
				return configName.hasSuffix( "ios:\( name )".lowercased() ) || configName.hasSuffix( "ios.sdk:\( name )".lowercased() )
			}
		}
		return config
	}

	public func findDoubleBy( _ ip: String, _ name: String, _ defaultValue: Double, _ needWarn: Bool = true ) -> Double
	{
		let config = self.findConfigBy( ip, name )
		if let exist = config { return exist.getValueDoubleOr( defaultValue ) }

		if ( needWarn ) { Log.Warn( "[DbConfig] NotFound the Config Key[\( name )] use defaultValue[\( defaultValue )]" ) }
		return defaultValue
	}

	public func findBoolBy( _ ip: String, _ name: String, _ defaultValue: Bool, _ needWarn: Bool = true ) -> Bool
	{
		let config = self.findConfigBy( ip, name )
		if let exist = config { return exist.getValueBoolOr( defaultValue ) }

		if ( needWarn ) { Log.Warn( "[DbConfig] NotFound the Config Key[\( name )] use defaultValue[\( defaultValue )]" ) }
		return defaultValue
	}

	public func findIntBy( _ ip: String, _ name: String, _ defaultValue: Int, _ needWarn: Bool = true ) -> Int
	{
		let config = self.findConfigBy( ip, name )
		if let exist = config { return exist.getValueIntOr( defaultValue ) }

		if ( needWarn ) { Log.Warn( "[DbConfig] NotFound the Config Key[\( name )] use defaultValue[\( defaultValue )]" ) }
		return defaultValue
	}

	public func findStrBy( _ ip: String, _ name: String, _ defaultValue: String, _ needWarn: Bool = true ) -> String
	{
		let config = self.findConfigBy( ip, name )
		if let exist = config { return exist.getValueStrOr( defaultValue ) }

		if ( needWarn ) { Log.Warn( "[DbConfig] NotFound the Config Key[\( name )] use defaultValue[\( defaultValue )]" ) }
		return defaultValue
	}
}

public class SdkConfigs: CustomStringConvertible
{
	public static private(set) var shared: SdkConfigs = SdkConfigs()

	public private(set) var holdSecond: Int = 30
	public private(set) var matchCount: Int = 20
	public private(set) var nameCount: Int = 0
	public private(set) var livingDetect: Bool = false
	public private(set) var livingThreshold: Double = 0.9
	public private(set) var livingCount: Int = 10

	public private(set) var smileDetect: Bool = true
	public private(set) var checkSmile: Bool = true
	public private(set) var trackingMatch_isTracking: Bool = true
	public private(set) var trackingMatch_threshold: Double = 1.5

	public private(set) var happyCount: Int = 2
	public private(set) var happyThreshold: Double = 0.9
	public private(set) var detectWithService_min_size: Int = 50

	public private(set) var requestTimeout: Double = 8.0
	public private(set) var tempCount: Int = 0

	init() {}

	public func ApplyBy( _ ip: String, _ configs: [dbConfig] )
	{
		holdSecond = configs.findIntBy( ip, "HoldSecond", 30 )
		matchCount = configs.findIntBy( ip, "MatchCount", 20 )
		nameCount = configs.findIntBy( ip, "NameCount", 0 )
		livingDetect = configs.findBoolBy( ip, "LivingDetect", true )
		livingThreshold = configs.findDoubleBy( ip, "LivingThreshold", 0.9 )
		livingCount = configs.findIntBy( ip, "LivingCount", 10 )
		smileDetect = configs.findBoolBy( ip, "SmileDetect", true )
		checkSmile = configs.findBoolBy( ip, "CheckSmile", true )
		trackingMatch_isTracking = configs.findBoolBy( ip, "TrackingMatch.is_tracking", true )
		trackingMatch_threshold = configs.findDoubleBy( ip, "TrackingMatch.threshold", 1.5 )
		happyCount = configs.findIntBy( ip, "HappyCount", 2 )
		happyThreshold = configs.findDoubleBy( ip, "HappyThreshold", 0.9 )
		detectWithService_min_size = configs.findIntBy( ip, "DetectWithService.min_size", 50 )

		requestTimeout = configs.findDoubleBy( ip, "RequestTimeout", 8.0 )
		tempCount = configs.findIntBy( ip, "TempCount", 0 )
	}

	public var description: String
	{
		var json = Json()
		json["requestTimeout"].doubleValue = self.requestTimeout
		json["holdSecond"].intValue = self.holdSecond
		json["matchCount"].intValue = self.matchCount
		json["nameCount"].intValue = self.nameCount
		json["livingDetect"].boolValue = self.livingDetect
		json["livingThreshold"].doubleValue = self.livingThreshold
		json["livingCount"].intValue = self.livingCount
		json["tempCount"].intValue = self.tempCount
		json["smileDetect"].boolValue = self.smileDetect
		json["checkSmile"].boolValue = self.checkSmile
		json["trackingMatch_isTracking"].boolValue = self.trackingMatch_isTracking
		json["trackingMatch_threshold"].doubleValue = self.trackingMatch_threshold
		json["happyCount"].intValue = self.happyCount
		json["happyThreshold"].doubleValue = self.happyThreshold
		json["DetectWithService_min_size"].intValue = self.detectWithService_min_size

		return "SdkConfigs[\( json.rawString() ?? "unknown SdkConfigs" )]"
	}
}
