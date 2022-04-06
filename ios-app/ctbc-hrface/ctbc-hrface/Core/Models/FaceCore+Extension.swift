import Foundation
import CtbcCore

#if !arch( x86_64 )
import FaceCore
#endif

extension FaceInfo
{
	public var json: Json
	{
		var json = Json()

		json["uuid"].string = self.uuid as String?

		json["id"].string = self.id as String?
		json["name"].string = self.name as String?

		json["happy"].bool = self.is_happy_detect
		json["living"].bool = self.is_living

		json["detect"].bool = self.is_detect ?? false
		json["punched"].bool = self.is_clock_in

		if let create_time = self.create_time { json["create_time"].string = create_time.toString() }

		return json
	}

	public var jsonStr: String
	{
		if #available( iOS 13.0, * )
		{
			return json.rawString( .utf8, options: [ .sortedKeys, .withoutEscapingSlashes ] ) ?? ""
		}
		else
		{
			return json.rawString()?.replace( "\n", "" ).replace( "\\\"", "\"" ) ?? ""
		}
	}
}
