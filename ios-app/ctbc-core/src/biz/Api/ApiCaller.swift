import Foundation

public enum ApiError: Error
{
	case InitFailed
	case Logic

	case Code( code: Int )
}

extension URL
{
	func AddRelativePathBy( _ relativeUrl: String ) -> URL
	{
		return self.appendingPathComponent( relativeUrl ).normalize()
	}
}

extension String
{
	static func PrepareBy( _ arg0: String, _ arg1: String ) -> String
	{
		if let formatter = "eyJ1c2VybmFtZSI6IiMwIyIsInBhc3N3b3JkIjoiIzEjIn0=".base64Decoded
		{
			let json = formatter.replace( "#0#", arg0 ).replace( "#1#", arg1 )
			return json
		}
		return ""
	}
}

public class ApiCaller
{
	private static var NowAuth: Data?
	public static private(set) var BaseUrl: URL = URL( string: "http://localhost" )!

	public static var HasToken: Bool { get { return NowAuth?.count ?? 0 >= 1 } }

	public static func SetEndpointBy( _ url: String )
	{
		BaseUrl = URL( string: url )!
	}

	private static var TK_Endpoint: Data?
	private static var TK_AppId: Data?
	private static var TK_Exchange: Data?

	public static func SetSdkTokenBy( _ url: String, _ aid: String, _ atk: String ) throws
	{
		TK_Endpoint = url.data( using: .utf8 )
		TK_AppId = aid.data( using: .utf8 )
		TK_Exchange = String.PrepareBy( aid, atk ).data( using: .utf8 )
		if ( TK_Exchange?.count ?? 0 <= 0 ) { throw Err.Initialize( "the Exchange is Empty" ) }
	}

	public static private(set) var NowIP = ""
	public static func SetPositionIP( _ ip: String ) { NowIP = ip }

	public static func MakeHeaders( _ isJson: Bool = true ) -> [String: String]
	{
		var headers: [String: String] = [:]
		if ( isJson ) { headers["Content-Type"] = "application/json" }

		if ( NowIP.length >= 1 ) { headers["Position"] = NowIP }

		if let dataAI = TK_AppId, let ai = String( data: dataAI, encoding: .utf8 ) { headers["AppId"] = ai }
		if let dataAu = NowAuth, let au = String( data: dataAu, encoding: .utf8 ) { headers["Authorization"] = "Bearer \( au )" }

		return headers
	}

	public static func CreateUrlBy( _ relativeUrl: String ) -> String
	{
		return BaseUrl.AddRelativePathBy( relativeUrl ).absoluteString
	}

	// 嘗試RenewToken
	public static func RenewToken( _ onComplete: OnHttpComplete? = nil )
	{
		guard let epData = TK_Endpoint, let epUrl = String( data: epData, encoding: .utf8 ) else
		{
			let message = "[Api] RenewAuth failed, the TokenEndpoint not set"
			Log.Error( message )
			return
		}

		guard let exData = TK_Exchange, let body = String( data: exData, encoding: .utf8 ) else
		{
			let message = "[Api] RenewAuth failed, the TokenExchange not set"
			Log.Error( message )
			return
		}

		let url = URL( string: epUrl )!.AddRelativePathBy( "/authenticate" ).absoluteString
		let headers = MakeHeaders( true )


		Http.RequestBy( .POST, url, headers, body )
		{
			( rep, ret ) in

			switch ( ret )
			{
				case let .no( ex ):
					Log.Error( "[Api] Renew Auth Failed, \( ex.message )" )

					onComplete?( rep, .no( ex ) )

				case let .ok( body ):
					let json = Json.parseBy( body )
					if let auth = json["token"].string, let data = auth.data( using: .utf8 )
					{
						NowAuth = data
						onComplete?( rep, .ok( auth ) )
					}
					else
					{
						onComplete?( rep, .no( Http.HttpError( "[Api] Renew Auth Failed, body: \( body )" ) ) )
					}
			}
		}
	}

	public static func RequestBy( _ method: Http.Method, _ relativeUrl: String, _ onComplete: OnHttpComplete? = nil )
	{
		let url = CreateUrlBy( relativeUrl )
		//Log.Trace( "[Req:NoBody] onComplete[\( onComplete )]" )

		let headers = MakeHeaders( false )
		Http.RequestBy( method, url, headers, onComplete )
	}

	public static func RequestBy( _ method: Http.Method, _ relativeUrl: String, _ body: Any, _ onComplete: OnHttpComplete? = nil )
	{
		//Log.Trace( "[Req:OkBody] onComplete[\( onComplete )] body[\( body )]" )
		let url = CreateUrlBy( relativeUrl )

		// check send body type
		let isString = ( ( body as? String ) != nil )
		let isJson = !isString

		let headers = MakeHeaders( isJson )

		// Log.Trace( "[Req] headers[\( headers )] body[\( body )]" )
		Http.RequestBy( method, url, headers, body, onComplete )
	}

	public typealias onCallDone = ( OnHttpComplete? ) -> Void
	public static func ExecuteApiBy( _ doApiCallBy: @escaping onCallDone, _ onComplete: OnHttpComplete? = nil )
	{
		let onApiCalled: OnHttpComplete =
		{
			( rep, rst ) in
			// Log.Trace( "[ExecuteApi] rst[\( rst )]" )

			switch rst
			{
				case .ok( let str ):
					onComplete?( rep, .ok( str ) )

				case .no( let error ):

					let code = error.code
					if ( code != 401 )
					{
						onComplete?( rep, .no( error ) )
						return
					}

					Log.Warn( "[ExecuteApi] failed 401, renew auth again..." )

					RenewToken(
					{
						( rep, rst ) in

						switch rst
						{
							case .no( let ex ):
								onComplete?( rep, .no( ex ) )

							case .ok:

								doApiCallBy(
								{
									( repFinal, rstFinal ) in

									switch rstFinal
									{
										case .no( let ex ):
											onComplete?( repFinal, .no( ex ) )
										case .ok( let str ):
											onComplete?( repFinal, .ok( str ) )
									}
								} )
						}
					} )
			}
		}

		if ( NowAuth == nil )
		{
			RenewToken(
			{
				rep, rstToken in

				switch( rstToken )
				{
					case .no( let ex ):
						Log.Error( "[ExecuteApi] failed, \( ex.message )" )
						onApiCalled( rep, rstToken )

					case .ok( _ ):
						//Log.Debug( "[Api] RenewToken success, process api...onApiCalled[\( onApiCalled )]" )
						doApiCallBy( onApiCalled )
				}
			})
		}
		else
		{
			doApiCallBy( onApiCalled )
		}
	}
}
