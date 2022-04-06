import Foundation

extension Decodable
{
	static func decode( data: Data ) throws -> Self
	{
		let decoder = JSONDecoder()
		return try decoder.decode( Self.self, from: data )
	}
}

extension Encodable
{
	func encode() -> Data?
	{
		let encoder = JSONEncoder()
		return try? encoder.encode( self )
	}

	var toJson: String
	{
		guard let data = self.encode() else { return "null" }

		return String( data: data, encoding: .utf8 ) ?? "null"
	}
}
