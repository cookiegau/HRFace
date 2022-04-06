import Foundation
import CtbcCore

public class AppConfigs: CustomStringConvertible
{
	public static let shared: AppConfigs = AppConfigs()

	private(set) var SDK_License_Endpoint: String = ""
	private(set) var SDK_License_Key: String = ""
	private(set) var SDK_Token_Endpoint: String = ""
	private(set) var SDK_Token_UserName: String = ""
	private(set) var SDK_Token_Password: String = ""
	private(set) var SDK_Service_Endpoint: String = ""
	private(set) var SDK_Log_Url: String = ""

	private(set) var LogsKeepDays: Int = 30

	private(set) var AirWatchSchemeName: String?

	init()
	{
	}


	public func LoadInfoPlistBy( _ dic: [String: Any] )
	{
		guard let urlTypes = dic["CFBundleURLTypes"] else { return }
		guard let items = urlTypes as? [Any] else { return }
		guard let dicInner = items[0] as? [String:Any] else { return }
		guard let urlSchemes = dicInner["CFBundleURLSchemes"] as? [String] else { return }
		guard urlSchemes.count > 0 else { return }

		self.AirWatchSchemeName = urlSchemes[0]
	}

	public func LoadConfigPlistBy( _ dic: [String: Any] )
	{
		self.SDK_License_Endpoint = dic.findBy( "SDK_License_Endpoint", "" )
		self.SDK_License_Key = dic.findBy( "SDK_License_Key", "" )
		self.SDK_Token_Endpoint = dic.findBy( "SDK_Token_Endpoint", "" )
		self.SDK_Token_UserName = dic.findBy( "SDK_Token_UserName", "" )
		self.SDK_Token_Password = dic.findBy( "SDK_Token_Password", "" )
		self.SDK_Service_Endpoint = dic.findBy( "SDK_Service_Endpoint", "" )
		self.SDK_Log_Url = dic.findBy( "SDK_Log_Url", "" )

		self.LogsKeepDays = dic.findIntBy( "Logs.KeepDays", 30 )
	}


	public var description: String
	{
		var json = Json()
		json["Logs.KeepDays"].intValue = self.LogsKeepDays

		return "AppConfigs[\( json.rawString() ?? "unknown AppConfigs" )]"
	}
}


class ConfigUtils
{
	public typealias OnLoadedAppConfigs = ( AppConfigs ) -> Void

	public static func LoadPlistBy( _ name: String ) throws -> [String: Any]
	{
		guard let fileUrl = Bundle.main.url( forResource: name, withExtension: "plist" ) else { throw Err.Initialize( "Please check the \( name ).plist" ) }
		guard let data = try? Data( contentsOf: fileUrl ) else { throw Err.Initialize( "Please check the \( name ).plist" ) }
		guard let loaded = try? PropertyListSerialization.propertyList( from: data, options: [], format: nil ) else { throw Err.Initialize( "The \( name ).plist cannot load" ) }
		guard let dic = loaded as? [String: Any] else { throw Err.Initialize( "The \( name ).plist cannot convert to Dictionary" ) }

		return dic
	}

	public static func LoadAppConfig( _ onLoaded: OnLoadedAppConfigs? = nil ) throws
	{
		let configs = AppConfigs.shared

		configs.LoadInfoPlistBy( try LoadPlistBy( "Info" ) )
		configs.LoadConfigPlistBy( try LoadPlistBy( "config" ) )

		if configs.SDK_License_Endpoint.length <= 0 { throw Err.Initialize( "config SDK_License_Endpoint not found" ) }
		if configs.SDK_License_Key.length <= 0 { throw Err.Initialize( "config SDK_License_Key not found" ) }
		if configs.SDK_Token_Endpoint.length <= 0 { throw Err.Initialize( "config SDK_Token_Endpoint not found" ) }
		if configs.SDK_Token_UserName.length <= 0 { throw Err.Initialize( "config SDK_Token_UserName not found" ) }
		if configs.SDK_Token_Password.length <= 0 { throw Err.Initialize( "config SDK_Token_Password not found" ) }
		if configs.SDK_Service_Endpoint.length <= 0 { throw Err.Initialize( "config SDK_Service_Endpoint not found" ) }
		if configs.SDK_Log_Url.length <= 0 { throw Err.Initialize( "config SDK_Log_Url not found" ) }

		onLoaded?( configs )
	}
}
