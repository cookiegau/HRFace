import Foundation

public enum JsonError: Int, Swift.Error
{
	case unsupportedType = 999
	case indexOutOfBounds = 900
	case elementTooDeep = 902
	case wrongType = 901
	case notExist = 500
	case invalidJson = 490
}

extension JsonError: CustomNSError
{
	public static var errorDomain: String { return "base.Json" }

	public var errorCode: Int { return self.rawValue }

	public var errorUserInfo: [String: Any]
	{
		switch self
		{
			case .unsupportedType:
				return [ NSLocalizedDescriptionKey: "It is an unsupported type." ]
			case .indexOutOfBounds:
				return [ NSLocalizedDescriptionKey: "Array Index is out of bounds." ]
			case .wrongType:
				return [ NSLocalizedDescriptionKey: "Couldn't merge, because the JSONs differ in type on top level." ]
			case .notExist:
				return [ NSLocalizedDescriptionKey: "Dictionary key does not exist." ]
			case .invalidJson:
				return [ NSLocalizedDescriptionKey: "JSON is invalid." ]
			case .elementTooDeep:
				return [ NSLocalizedDescriptionKey: "Element too deep. Increase maxObjectDepth and make sure there is no reference loop." ]
		}
	}
}

// type definitions http://www.json.org
public enum JsonType: Int
{
	case number
	case string
	case bool
	case array
	case dictionary
	case null
	case unknown
}

extension Json
{
	public static func parseBy( _ string: String ) -> Json
	{
		return Json( parseString: string )
	}

	public func PrintItems()
	{
		for ( key, item ): ( String, Json ) in self
		{
			print( "items: key[\( key )] type[\( item.type )] error[\( item.error.debugDescription )] value[\( item )]" )
		}
	}
}

public struct Json
{
	// The NSData used to convert to json.Top level object in data is an NSArray or NSDictionary
	public init( data: Data, options opt: JSONSerialization.ReadingOptions = [] ) throws
	{
		let object: Any = try JSONSerialization.jsonObject( with: data, options: opt )
		self.init( jsonObject: object )
	}

	// create json from object, but does not parse string
	public init( _ object: Any )
	{
		switch object
		{
			case let object as Data:
				do
				{
					try self.init( data: object )
				}
				catch
				{
					self.init( jsonObject: NSNull() )
				}
			default:
				self.init( jsonObject: object )
		}
	}

	// create json from string
	public init( parseString jsonString: String )
	{
		if let data = jsonString.data( using: .utf8 )
		{
			self.init( data )
		}
		else
		{
			self.init( NSNull() )
		}
	}

	// The object must have the following properties:
	// All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary,
	// or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.
	fileprivate init( jsonObject: Any )
	{
		object = jsonObject
	}

	/**
	 Merges another JSON into this JSON, whereas primitive values which are not present in this JSON are getting added,
	 present values getting overwritten, array values getting appended and nested JSONs getting merged the same way.
	 - parameter other: The JSON which gets merged into this JSON
	 - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
	 */
	public mutating func merge( with other: Json ) throws
	{
		try self.merge( with: other, typeCheck: true )
	}

	/**
	 Merges another JSON into this JSON and returns a new JSON, whereas primitive values which are not present in this JSON are getting added,
	 present values getting overwritten, array values getting appended and nested JSONS getting merged the same way.

	 - parameter other: The JSON which gets merged into this JSON
	 - throws `JsonError.WrongType` if the other JSONs differs in type on the top level.
	 - returns: New merged JSON
	 */
	public func merged( with other: Json ) throws -> Json
	{
		var merged = self
		try merged.merge( with: other, typeCheck: true )
		return merged
	}

	/**
	 Private worker function which does the actual merging
	 TypeCheck is set to true for the first recursion level to prevent total override of the source JSON
	 */
	fileprivate mutating func merge( with other: Json, typeCheck: Bool ) throws
	{
		if type == other.type
		{
			switch type
			{
				case .dictionary:
					for ( key, _ ) in other
					{
						try self[key].merge( with: other[key], typeCheck: false )
					}
				case .array:
					self = Json( arrayValue + other.arrayValue )
				default:
					self = other
			}
		}
		else
		{
			if typeCheck
			{
				throw JsonError.wrongType
			}
			else
			{
				self = other
			}
		}
	}

	/// Private object
	fileprivate var rawArray: [Any] = []
	fileprivate var rawDictionary: [String: Any] = [:]
	fileprivate var rawString: String = ""
	fileprivate var rawNumber: NSNumber = 0
	fileprivate var rawNull: NSNull = NSNull()
	fileprivate var rawBool: Bool = false

	/// JSON type, fileprivate setter
	public fileprivate(set) var type: JsonType = .null

	/// Error in JSON, fileprivate setter
	public fileprivate(set) var error: JsonError?

	/// Object in JSON
	public var object: Any
	{
		get
		{
			switch type
			{
				case .array:      return rawArray
				case .dictionary: return rawDictionary
				case .string:     return rawString
				case .number:     return rawNumber
				case .bool:       return rawBool
				default:          return rawNull
			}
		}
		set
		{
			error = nil
			switch unwrap( newValue )
			{
				case let number as NSNumber:
					if number.isBool
					{
						type = .bool
						rawBool = number.boolValue
					}
					else
					{
						type = .number
						rawNumber = number
					}
				case let string as String:
					type = .string
					rawString = string
				case _ as NSNull:
					type = .null
				case nil:
					type = .null
				case let array as [Any]:
					type = .array
					rawArray = array
				case let dictionary as [String: Any]:
					type = .dictionary
					rawDictionary = dictionary
				default:
					type = .unknown
					error = JsonError.unsupportedType
			}
		}
	}

	/// The static null JSON
	@available( *, unavailable, renamed: "null" )
	public static var nullJSON: Json { return null }
	public static var null: Json { return Json( NSNull() ) }
}

/// Private method to unwrap an object recursively
private func unwrap( _ object: Any ) -> Any
{
	switch object
	{
		case let json as Json:
			return unwrap( json.object )
		case let array as [Any]:
			return array.map( unwrap )
		case let dictionary as [String: Any]:
			var d = dictionary
			dictionary.forEach
			{ pair in
				d[pair.key] = unwrap( pair.value )
			}
			return d
		default:
			return object
	}
}

public enum Index<T: Any>: Comparable
{
	case array( Int )
	case dictionary( DictionaryIndex<String, T> )
	case null

	static public func ==( lhs: Index, rhs: Index ) -> Bool
	{
		switch ( lhs, rhs )
		{
			case ( .array( let left ), .array( let right ) ):           return left == right
			case ( .dictionary( let left ), .dictionary( let right ) ): return left == right
			case ( .null, .null ):                                        return true
			default:                                                    return false
		}
	}

	static public func <( lhs: Index, rhs: Index ) -> Bool
	{
		switch ( lhs, rhs )
		{
			case ( .array( let left ), .array( let right ) ):           return left < right
			case ( .dictionary( let left ), .dictionary( let right ) ): return left < right
			default:                                                    return false
		}
	}
}

public typealias JsonIndex = Index<Json>
public typealias JsonRawIndex = Index<Any>

extension Json: Swift.Collection
{

	public typealias Index = JsonRawIndex

	public var startIndex: Index
	{
		switch type
		{
			case .array:      return .array( rawArray.startIndex )
			case .dictionary: return .dictionary( rawDictionary.startIndex )
			default:          return .null
		}
	}

	public var endIndex: Index
	{
		switch type
		{
			case .array:      return .array( rawArray.endIndex )
			case .dictionary: return .dictionary( rawDictionary.endIndex )
			default:          return .null
		}
	}

	public func index( after i: Index ) -> Index
	{
		switch i
		{
			case .array( let idx ):      return .array( rawArray.index( after: idx ) )
			case .dictionary( let idx ): return .dictionary( rawDictionary.index( after: idx ) )
			default:                   return .null
		}
	}

	public subscript( position: Index ) -> ( String, Json )
	{
		switch position
		{
			case .array( let idx ):      return ( String( idx ), Json( rawArray[idx] ) )
			case .dictionary( let idx ): return ( rawDictionary[idx].key, Json( rawDictionary[idx].value ) )
			default:                   return ( "", Json.null )
		}
	}
}

// To mark both String and Int can be used in subscript.
public enum JsonKey
{
	case index( Int )
	case key( String )
}

public protocol JsonSubscriptType
{
	var jsonKey: JsonKey { get }
}

extension Int: JsonSubscriptType
{
	public var jsonKey: JsonKey
	{
		return JsonKey.index( self )
	}
}

extension String: JsonSubscriptType
{
	public var jsonKey: JsonKey
	{
		return JsonKey.key( self )
	}
}

extension Json
{
	/// If `type` is `.array`, return json whose object is `array[index]`, otherwise return null json with error.
	fileprivate subscript( index index: Int ) -> Json
	{
		get
		{
			if type != .array
			{
				var r = Json.null
				r.error = self.error ?? JsonError.wrongType
				return r
			}
			else if rawArray.indices.contains( index )
			{
				return Json( rawArray[index] )
			}
			else
			{
				var r = Json.null
				r.error = JsonError.indexOutOfBounds
				return r
			}
		}
		set
		{
			if type == .array && rawArray.indices.contains( index ) && newValue.error == nil
			{
				rawArray[index] = newValue.object
			}
		}
	}

	/// If `type` is `.dictionary`, return json whose object is `dictionary[key]` , otherwise return null json with error.
	fileprivate subscript( key key: String ) -> Json
	{
		get
		{
			var r = Json.null
			if type == .dictionary
			{
				if let o = rawDictionary[key]
				{
					r = Json( o )
				}
				else
				{
					r.error = JsonError.notExist
				}
			}
			else
			{
				r.error = self.error ?? JsonError.wrongType
			}
			return r
		}
		set
		{
			if type == .dictionary && newValue.error == nil
			{
				rawDictionary[key] = newValue.object
			}
		}
	}

	/// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
	fileprivate subscript( sub sub: JsonSubscriptType ) -> Json
	{
		get
		{
			switch sub.jsonKey
			{
				case .index( let index ): return self[index: index]
				case .key( let key ):     return self[key: key]
			}
		}
		set
		{
			switch sub.jsonKey
			{
				case .index( let index ): self[index: index] = newValue
				case .key( let key ):     self[key: key] = newValue
			}
		}
	}

	/**
	 Find a json in the complex data structures by using array of Int and/or String as path.

	 Example:

	 ```
	 let json = JSON[data]
	 let path = [9,"list","person","name"]
	 let name = json[path]
	 ```

	 The same as: let name = json[9]["list"]["person"]["name"]

	 - parameter path: The target jsons path.

	 - returns: Return a json found by the path or a null json with error
	 */
	public subscript( path: [JsonSubscriptType] ) -> Json
	{
		get { return path.reduce( self ) { $0[sub: $1] } }
		set
		{
			switch path.count
			{
				case 0: return
				case 1: self[sub: path[0]].object = newValue.object
				default:
					var aPath = path
					aPath.remove( at: 0 )
					var nextJSON = self[sub: path[0]]
					nextJSON[aPath] = newValue
					self[sub: path[0]] = nextJSON
			}
		}
	}

	/**
	 Find a json in the complex data structures by using array of Int and/or String as path.

	 - parameter path: The target jsons path. Example:

	 let name = json[9,"list","person","name"]

	 The same as: let name = json[9]["list"]["person"]["name"]

	 - returns: Return a json found by the path or a null json with error
	 */
	public subscript( path: JsonSubscriptType... ) -> Json
	{
		get { return self[path] }
		set { self[path] = newValue }
	}
}

extension Json: Swift.ExpressibleByStringLiteral
{

	public init( stringLiteral value: StringLiteralType )
	{
		self.init( value )
	}

	public init( extendedGraphemeClusterLiteral value: StringLiteralType )
	{
		self.init( value )
	}

	public init( unicodeScalarLiteral value: StringLiteralType )
	{
		self.init( value )
	}
}

extension Json: Swift.ExpressibleByIntegerLiteral
{

	public init( integerLiteral value: IntegerLiteralType )
	{
		self.init( value )
	}
}

extension Json: Swift.ExpressibleByBooleanLiteral
{

	public init( booleanLiteral value: BooleanLiteralType )
	{
		self.init( value )
	}
}

extension Json: Swift.ExpressibleByFloatLiteral
{

	public init( floatLiteral value: FloatLiteralType )
	{
		self.init( value )
	}
}

extension Json: Swift.ExpressibleByDictionaryLiteral
{
	public init( dictionaryLiteral elements: ( String, Any )... )
	{
		let dictionary = elements.reduce( into: [ String: Any ](), { $0[$1.0] = $1.1 } )
		self.init( dictionary )
	}
}

extension Json: Swift.ExpressibleByArrayLiteral
{

	public init( arrayLiteral elements: Any... )
	{
		self.init( elements )
	}
}

extension Json: Swift.RawRepresentable
{

	public init?( rawValue: Any )
	{
		if Json( rawValue ).type == .unknown
		{
			return nil
		}
		else
		{
			self.init( rawValue )
		}
	}

	public var rawValue: Any
	{
		return object
	}

	public func rawData( options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions( rawValue: 0 ) ) throws -> Data
	{
		guard JSONSerialization.isValidJSONObject( object ) else
		{
			throw JsonError.invalidJson
		}

		return try JSONSerialization.data( withJSONObject: object, options: opt )
	}

	public func rawString( _ encoding: String.Encoding = .utf8, options opt: JSONSerialization.WritingOptions = [ .prettyPrinted, .sortedKeys ] ) -> String?
	{
		do
		{
			return try _rawString( encoding, options: [ .jsonSerialization: opt ] )
		}
		catch
		{
			print( "Could not serialize object to JSON because:", error.localizedDescription )
			return nil
		}
	}

	public func rawString( _ options: [JsonWriteOptionKeys: Any] ) -> String?
	{
		let encoding = options[.encoding] as? String.Encoding ?? String.Encoding.utf8
		let maxObjectDepth = options[.maxObjectDepth] as? Int ?? 10
		do
		{
			return try _rawString( encoding, options: options, maxObjectDepth: maxObjectDepth )
		}
		catch
		{
			print( "Could not serialize object to JSON because:", error.localizedDescription )
			return nil
		}
	}

	fileprivate func _rawString( _ encoding: String.Encoding = .utf8, options: [JsonWriteOptionKeys: Any], maxObjectDepth: Int = 10 ) throws -> String?
	{
		guard maxObjectDepth > 0 else { throw JsonError.invalidJson }
		switch type
		{
			case .dictionary:
				do
				{
					if !( options[.castNilToNSNull] as? Bool ?? false )
					{
						let jsonOption = options[.jsonSerialization] as? JSONSerialization.WritingOptions ?? JSONSerialization.WritingOptions.prettyPrinted
						let data = try rawData( options: jsonOption )
						return String( data: data, encoding: encoding )
					}

					guard let dict = object as? [String: Any?] else
					{
						return nil
					}
					let body = try dict.keys.map
					{
						key throws -> String in

						guard let value = dict[key] else
						{
							return "\"\( key )\": null"
						}
						guard let unwrappedValue = value else
						{
							return "\"\( key )\": null"
						}

						let nestedValue = Json( unwrappedValue )
						guard let nestedString = try nestedValue._rawString( encoding, options: options, maxObjectDepth: maxObjectDepth - 1 ) else
						{
							throw JsonError.elementTooDeep
						}
						if nestedValue.type == .string
						{
							return "\"\( key )\": \"\( nestedString.replacingOccurrences( of: "\\", with: "\\\\" ).replacingOccurrences( of: "\"", with: "\\\"" ) )\""
						}
						else
						{
							return "\"\( key )\": \( nestedString )"
						}
					}

					return "{\( body.joined( separator: "," ) )}"
				}
				catch _
				{
					return nil
				}
			case .array:
				do
				{
					if !( options[.castNilToNSNull] as? Bool ?? false )
					{
						let jsonOption = options[.jsonSerialization] as? JSONSerialization.WritingOptions ?? JSONSerialization.WritingOptions.prettyPrinted
						let data = try rawData( options: jsonOption )
						return String( data: data, encoding: encoding )
					}

					guard let array = object as? [Any?] else
					{
						return nil
					}
					let body = try array.map
					{ value throws -> String in
						guard let unwrappedValue = value else
						{
							return "null"
						}

						let nestedValue = Json( unwrappedValue )
						guard let nestedString = try nestedValue._rawString( encoding, options: options, maxObjectDepth: maxObjectDepth - 1 ) else
						{
							throw JsonError.invalidJson
						}
						if nestedValue.type == .string
						{
							return "\"\( nestedString.replacingOccurrences( of: "\\", with: "\\\\" ).replacingOccurrences( of: "\"", with: "\\\"" ) )\""
						}
						else
						{
							return nestedString
						}
					}

					return "[\( body.joined( separator: "," ) )]"
				}
				catch _
				{
					return nil
				}
			case .string: return rawString
			case .number: return rawNumber.stringValue
			case .bool:   return rawBool.description
			case .null:   return "null"
			default:      return nil
		}
	}
}

extension Json: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible
{
	public var description: String
	{
		return rawString( options: .prettyPrinted ) ?? "unknown"
	}

	public var debugDescription: String
	{
		return description
	}
}

extension Json
{
	public var array: [Json]?
	{
		return type == .array ? rawArray.map { Json( $0 ) } : nil
	}

	public var arrayValue: [Json]
	{
		return self.array ?? []
	}

	public var arrayObject: [Any]?
	{
		get
		{
			switch type
			{
				case .array: return rawArray
				default:     return nil
			}
		}
		set
		{
			self.object = newValue ?? NSNull()
		}
	}
}

extension Json
{
	public var dictionary: [String: Json]?
	{
		if type == .dictionary
		{
			var dic = [ String: Json ]( minimumCapacity: rawDictionary.count )
			rawDictionary.forEach
			{ pair in
				dic[pair.key] = Json( pair.value )
			}
			return dic
		}
		else
		{
			return nil
		}
	}

	public var dictionaryValue: [String: Json]
	{
		return dictionary ?? [:]
	}

	public var dictionaryObject: [String: Any]?
	{
		get
		{
			switch type
			{
				case .dictionary: return rawDictionary
				default:          return nil
			}
		}
		set { object = newValue ?? NSNull() }
	}
}

extension Json
{
	public var bool: Bool?
	{
		get
		{
			switch type
			{
				case .bool: return rawBool
				default:    return nil
			}
		}
		set { object = newValue ?? NSNull() }
	}

	public var boolValue: Bool
	{
		get
		{
			switch type
			{
				case .bool:   return rawBool
				case .number: return rawNumber.boolValue
				case .string: return [ "true", "y", "t", "yes", "1" ].contains { rawString.caseInsensitiveCompare( $0 ) == .orderedSame }
				default:      return false
			}
		}
		set { object = newValue }
	}
}

extension Json
{
	public var string: String?
	{
		get
		{
			switch type
			{
				case .string: return object as? String
				default:      return nil
			}
		}
		set { object = newValue ?? NSNull() }
	}

	public var stringValue: String
	{
		get
		{
			switch type
			{
				case .string: return object as? String ?? ""
				case .number: return rawNumber.stringValue
				case .bool:   return ( object as? Bool ).map { String( $0 ) } ?? ""
				default:      return ""
			}
		}
		set { object = newValue }
	}
}

extension Json
{
	public var number: NSNumber?
	{
		get
		{
			switch type
			{
				case .number: return rawNumber
				case .bool:   return NSNumber( value: rawBool ? 1 : 0 )
				default:      return nil
			}
		}
		set { object = newValue ?? NSNull() }
	}

	public var numberValue: NSNumber
	{
		get
		{
			switch type
			{
				case .string:
					let decimal = NSDecimalNumber( string: object as? String )
					return decimal == .notANumber ? .zero : decimal
				case .number: return object as? NSNumber ?? NSNumber( value: 0 )
				case .bool: return NSNumber( value: rawBool ? 1 : 0 )
				default: return NSNumber( value: 0.0 )
			}
		}
		set { object = newValue }
	}
}

extension Json
{

	public var null: NSNull?
	{
		set { object = NSNull() }
		get
		{
			switch type
			{
				case .null: return rawNull
				default:    return nil
			}
		}
	}

	public func exists() -> Bool
	{
		if let errorValue = error, ( 400 ... 1000 ).contains( errorValue.errorCode ) { return false }
		return true
	}
}

extension Json
{
	public var url: URL?
	{
		get
		{
			switch type
			{
				case .string:
					// Check for existing percent escapes first to prevent double-escaping of % character
					if rawString.range( of: "%[0-9A-Fa-f]{2}", options: .regularExpression, range: nil, locale: nil ) != nil
					{
						return Foundation.URL( string: rawString )
					}
					else if let encodedString_ = rawString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed )
					{
						// We have to use `Foundation.URL` otherwise it conflicts with the variable name.
						return Foundation.URL( string: encodedString_ )
					}
					else
					{
						return nil
					}
				default:
					return nil
			}
		}
		set { object = newValue?.absoluteString ?? NSNull() }
	}
}

extension Json
{

	public var double: Double?
	{
		get { return number?.doubleValue }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var doubleValue: Double
	{
		get { return numberValue.doubleValue }
		set { object = NSNumber( value: newValue ) }
	}

	public var float: Float?
	{
		get { return number?.floatValue }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var floatValue: Float
	{
		get { return numberValue.floatValue }
		set { object = NSNumber( value: newValue ) }
	}

	public var int: Int?
	{
		get { return number?.intValue }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var intValue: Int
	{
		get { return numberValue.intValue }
		set { object = NSNumber( value: newValue ) }
	}

	public var uInt: UInt?
	{
		get { return number?.uintValue }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var uIntValue: UInt
	{
		get { return numberValue.uintValue }
		set { object = NSNumber( value: newValue ) }
	}

	public var int8: Int8?
	{
		get { return number?.int8Value }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: Int( newValue ) )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var int8Value: Int8
	{
		get { return numberValue.int8Value }
		set { object = NSNumber( value: Int( newValue ) ) }
	}

	public var uInt8: UInt8?
	{
		get { return number?.uint8Value }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var uInt8Value: UInt8
	{
		get { return numberValue.uint8Value }
		set { object = NSNumber( value: newValue ) }
	}

	public var int16: Int16?
	{
		get { return number?.int16Value }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var int16Value: Int16
	{
		get { return numberValue.int16Value }
		set { object = NSNumber( value: newValue ) }
	}

	public var uInt16: UInt16?
	{
		get { return number?.uint16Value }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var uInt16Value: UInt16
	{
		get { return numberValue.uint16Value }
		set { object = NSNumber( value: newValue ) }
	}

	public var int32: Int32?
	{
		get { return number?.int32Value }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var int32Value: Int32
	{
		get { return numberValue.int32Value }
		set { object = NSNumber( value: newValue ) }
	}

	public var uInt32: UInt32?
	{
		get { return number?.uint32Value }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var uInt32Value: UInt32
	{
		get { return numberValue.uint32Value }
		set { object = NSNumber( value: newValue ) }
	}

	public var int64: Int64?
	{
		get { return number?.int64Value }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var int64Value: Int64
	{
		get { return numberValue.int64Value }
		set { object = NSNumber( value: newValue ) }
	}

	public var uInt64: UInt64?
	{
		get { return number?.uint64Value }
		set
		{
			if let newValue = newValue
			{
				object = NSNumber( value: newValue )
			}
			else
			{
				object = NSNull()
			}
		}
	}

	public var uInt64Value: UInt64
	{
		get { return numberValue.uint64Value }
		set { object = NSNumber( value: newValue ) }
	}
}

extension Json: Swift.Comparable
{
}

public func ==( lhs: Json, rhs: Json ) -> Bool
{

	switch ( lhs.type, rhs.type )
	{
		case ( .number, .number ): return lhs.rawNumber == rhs.rawNumber
		case ( .string, .string ): return lhs.rawString == rhs.rawString
		case ( .bool, .bool ):     return lhs.rawBool == rhs.rawBool
		case ( .array, .array ):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
		case ( .dictionary, .dictionary ): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
		case ( .null, .null ):     return true
		default:                 return false
	}
}

public func <=( lhs: Json, rhs: Json ) -> Bool
{

	switch ( lhs.type, rhs.type )
	{
		case ( .number, .number ): return lhs.rawNumber <= rhs.rawNumber
		case ( .string, .string ): return lhs.rawString <= rhs.rawString
		case ( .bool, .bool ):     return lhs.rawBool == rhs.rawBool
		case ( .array, .array ):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
		case ( .dictionary, .dictionary ): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
		case ( .null, .null ):     return true
		default:                 return false
	}
}

public func >=( lhs: Json, rhs: Json ) -> Bool
{

	switch ( lhs.type, rhs.type )
	{
		case ( .number, .number ): return lhs.rawNumber >= rhs.rawNumber
		case ( .string, .string ): return lhs.rawString >= rhs.rawString
		case ( .bool, .bool ):     return lhs.rawBool == rhs.rawBool
		case ( .array, .array ):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
		case ( .dictionary, .dictionary ): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
		case ( .null, .null ):     return true
		default:                 return false
	}
}

public func >( lhs: Json, rhs: Json ) -> Bool
{

	switch ( lhs.type, rhs.type )
	{
		case ( .number, .number ): return lhs.rawNumber > rhs.rawNumber
		case ( .string, .string ): return lhs.rawString > rhs.rawString
		default:                 return false
	}
}

public func <( lhs: Json, rhs: Json ) -> Bool
{

	switch ( lhs.type, rhs.type )
	{
		case ( .number, .number ): return lhs.rawNumber < rhs.rawNumber
		case ( .string, .string ): return lhs.rawString < rhs.rawString
		default:                 return false
	}
}

private let trueNumber = NSNumber( value: true )
private let falseNumber = NSNumber( value: false )
private let trueObjCType = String( cString: trueNumber.objCType )
private let falseObjCType = String( cString: falseNumber.objCType )

extension NSNumber
{
	fileprivate var isBool: Bool
	{
		let objCType = String( cString: self.objCType )
		if ( self.compare( trueNumber ) == .orderedSame && objCType == trueObjCType ) || ( self.compare( falseNumber ) == .orderedSame && objCType == falseObjCType )
		{
			return true
		}
		else
		{
			return false
		}
	}
}

func ==( lhs: NSNumber, rhs: NSNumber ) -> Bool
{
	switch ( lhs.isBool, rhs.isBool )
	{
		case ( false, true ): return false
		case ( true, false ): return false
		default:            return lhs.compare( rhs ) == .orderedSame
	}
}

func !=( lhs: NSNumber, rhs: NSNumber ) -> Bool
{
	return !( lhs == rhs )
}

func <( lhs: NSNumber, rhs: NSNumber ) -> Bool
{

	switch ( lhs.isBool, rhs.isBool )
	{
		case ( false, true ): return false
		case ( true, false ): return false
		default:            return lhs.compare( rhs ) == .orderedAscending
	}
}

func >( lhs: NSNumber, rhs: NSNumber ) -> Bool
{

	switch ( lhs.isBool, rhs.isBool )
	{
		case ( false, true ): return false
		case ( true, false ): return false
		default:            return lhs.compare( rhs ) == ComparisonResult.orderedDescending
	}
}

func <=( lhs: NSNumber, rhs: NSNumber ) -> Bool
{

	switch ( lhs.isBool, rhs.isBool )
	{
		case ( false, true ): return false
		case ( true, false ): return false
		default:            return lhs.compare( rhs ) != .orderedDescending
	}
}

func >=( lhs: NSNumber, rhs: NSNumber ) -> Bool
{

	switch ( lhs.isBool, rhs.isBool )
	{
		case ( false, true ): return false
		case ( true, false ): return false
		default:            return lhs.compare( rhs ) != .orderedAscending
	}
}

public enum JsonWriteOptionKeys
{
	case jsonSerialization
	case castNilToNSNull
	case maxObjectDepth
	case encoding
}

extension Json: Codable
{
	private static var codableTypes: [Codable.Type]
	{
		return [
			Bool.self,
			Int.self,
			Int8.self,
			Int16.self,
			Int32.self,
			Int64.self,
			UInt.self,
			UInt8.self,
			UInt16.self,
			UInt32.self,
			UInt64.self,
			Double.self,
			String.self,
			[ Json ].self,
			[ String: Json ].self
		]
	}

	public init( from decoder: Decoder ) throws
	{
		var object: Any?

		if let container = try? decoder.singleValueContainer(), !container.decodeNil()
		{
			for type in Json.codableTypes
			{
				if object != nil
				{
					break
				}
				// try to decode value
				switch type
				{
					case let boolType as Bool.Type:
						object = try? container.decode( boolType )
					case let intType as Int.Type:
						object = try? container.decode( intType )
					case let int8Type as Int8.Type:
						object = try? container.decode( int8Type )
					case let int32Type as Int32.Type:
						object = try? container.decode( int32Type )
					case let int64Type as Int64.Type:
						object = try? container.decode( int64Type )
					case let uintType as UInt.Type:
						object = try? container.decode( uintType )
					case let uint8Type as UInt8.Type:
						object = try? container.decode( uint8Type )
					case let uint16Type as UInt16.Type:
						object = try? container.decode( uint16Type )
					case let uint32Type as UInt32.Type:
						object = try? container.decode( uint32Type )
					case let uint64Type as UInt64.Type:
						object = try? container.decode( uint64Type )
					case let doubleType as Double.Type:
						object = try? container.decode( doubleType )
					case let stringType as String.Type:
						object = try? container.decode( stringType )
					case let jsonValueArrayType as [Json].Type:
						object = try? container.decode( jsonValueArrayType )
					case let jsonValueDictType as [String: Json].Type:
						object = try? container.decode( jsonValueDictType )
					default:
						break
				}
			}
		}
		self.init( object ?? NSNull() )
	}

	public func encode( to encoder: Encoder ) throws
	{
		var container = encoder.singleValueContainer()
		if object is NSNull
		{
			try container.encodeNil()
			return
		}
		switch object
		{
			case let intValue as Int:
				try container.encode( intValue )
			case let int8Value as Int8:
				try container.encode( int8Value )
			case let int32Value as Int32:
				try container.encode( int32Value )
			case let int64Value as Int64:
				try container.encode( int64Value )
			case let uintValue as UInt:
				try container.encode( uintValue )
			case let uint8Value as UInt8:
				try container.encode( uint8Value )
			case let uint16Value as UInt16:
				try container.encode( uint16Value )
			case let uint32Value as UInt32:
				try container.encode( uint32Value )
			case let uint64Value as UInt64:
				try container.encode( uint64Value )
			case let doubleValue as Double:
				try container.encode( doubleValue )
			case let boolValue as Bool:
				try container.encode( boolValue )
			case let stringValue as String:
				try container.encode( stringValue )
			case is [Any]:
				let jsonValueArray = array ?? []
				try container.encode( jsonValueArray )
			case is [String: Any]:
				let jsonValueDictValue = dictionary ?? [:]
				try container.encode( jsonValueDictValue )
			default:
				break
		}
	}
}
