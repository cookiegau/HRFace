import Foundation

public class IPadFeature
{
	public private(set) var uuid: String
	public private(set) var staffId: String
	public private(set) var feature: [Double]
	public private(set) var createdBy: String

	public init( _ uuid: String, _ staffId: String, _ feature: [Double], _ createdBy: String )
	{
		self.uuid = uuid
		self.staffId = staffId
		self.feature = feature
		self.createdBy = createdBy
	}

	var json: String
	{
		get { return self.description }
	}
}

extension IPadFeature: CustomStringConvertible
{
	public var description: String
	{
		var json = Json()
		json["uuid"].stringValue = self.uuid
		json["staffId"].stringValue = self.staffId
		json["feature"].arrayObject = self.feature
		json["createdBy"].stringValue = self.createdBy

		return json.rawString( .utf8, options: [ .sortedKeys ] ) ?? "{}"
	}
}

