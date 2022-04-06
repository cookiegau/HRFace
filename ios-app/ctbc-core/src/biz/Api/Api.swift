import Foundation

public class Api: ApiCaller
{
	public static private(set) var IsAvailable = false
	public static private(set) var CountHtbtOk = 0
	public static private(set) var CountHtbtNo = 0
	public static private(set) var TimerHtbt: Timer!

	public static private(set) var Aes = ""

	public static func StartAutoCheck()
	{
		let action =
		{
			Api.HtbtBy
			{
				rep, ex in
				if ex != nil
				{
					Api.CountHtbtNo += 1
					self.IsAvailable = false
				}
				else
				{
					Api.CountHtbtOk += 1
					self.IsAvailable = true
				}
			}
		}

		action()
		TimerHtbt = Timer.scheduledTimer( withTimeInterval: 5.0, repeats: true ) { _ in action() }
	}

	public static func HtbtBy( _ onDone: @escaping ( Http.HttpResponse, Http.HttpError? ) -> Void )
	{
		Api.ExecuteApiBy( { onDone in Api.RequestBy( .GET, "/htbt", onDone ) },
		{
			rep, ret in

			switch ret
			{
				case .no( let ex ):
					Log.Debug( "[Api:Htbt] Failed code[(\( ex.code ))] message[\( ex.message )] error[\( ex.error )]" )
					onDone( rep, ex )
				case .ok( _ ):
					onDone( rep, nil )
			}
		} )
	}

	static var dtConfigShowLast = Date().addingTimeInterval( -50 )
	static var dtLastShowItems = Date().addingTimeInterval( -( 60 * 12 ) )

	// 取得configs: /config/all
	public static func GetConfigs( _ onSuccess: @escaping ( _ json: [dbConfig] ) -> Void )
	{
		let dtS = Date()
		Log.Debug( "[Api:Config] fetching..." )
		Api.ExecuteApiBy( { onDone in Api.RequestBy( .GET, "/config/all", onDone ) },
		{
			rep, ret in

			switch ret
			{
				case .no( let ex ):
					Log.Error( "[Api:Config] 取得設定檔失敗, \( ex.message )" )
					onSuccess( [] )
				case .ok( let body ):
					let configs = dbConfig.parseModelsBy( body, false )

					//------------------------------------------------------------------------
					let dtNow = Date()

					var logMessage = "[Api:Config] fetched, items[\( configs.count )] response time[\( rep.duration.milliseconds )]"
					if ( dtS.timeIntervalSince( dtLastShowItems ) >= ( 60 * 10 ) )
					{
						logMessage = logMessage + " items[\( configs.count )]: \( String( describing: configs ) ) )"
						dtLastShowItems = dtS
					}


					let secs = dtNow.timeIntervalSince( Api.dtConfigShowLast )
					if ( secs <= ( 30 ) )
					{
						Log.Debug( logMessage )
					}
					else
					{
						Log.Info( logMessage )
						Api.dtConfigShowLast = Date()
					}

					//------------------------------------------------------------------------
					// process EncodeKey
					//------------------------------------------------------------------------
					let configAesB64 = configs.findStrBy( "", "EncodeKey", "" )
					if ( configAesB64.length > 0 )
					{
						if let varAes = configAesB64.base64Decoded?.replace( "\n", "" )
						{
							if ( varAes.length % 16 == 0 )
							{
								Api.Aes = varAes
								//Log.Debug( "[Api] Aes[\( Api.Aes )]" )
							}
							else
							{
								Api.Aes = ""
								Log.Warn( "[Api] config EncodeKey not valid length[\( varAes.length )]" )
							}
						}
						else
						{
							Api.Aes = ""
							Log.Warn( "[Api] config EncodeKey not valid base64 string[\( configAesB64 )]" )
						}
					}
					else
					{
						Api.Aes = ""
					}


					//------------------------------------------------------------------------
					// vars
					//------------------------------------------------------------------------
					RtVars.IsAllowLocalLog = configs.findBoolBy( Api.NowIP, "AllowLocalLog", true, false )
					RtVars.IsAllowServerLog = configs.findBoolBy( Api.NowIP, "AllowServerLog", true, false )
					RtVars.IsServerLogFullMode = configs.findBoolBy( Api.NowIP, "ServerLogFullMode", true, false )


					RtVars.IsEnableFeatureAdmin = configs.findBoolBy( Api.NowIP, "FeatureAdminEnable", false, false )

					RtVars.IsDisableButtons = configs.findBoolBy( Api.NowIP, "DisableButtons", false, false )
					RtVars.MaintainMessage = configs.findStrBy( Api.NowIP, "MaintainMessage", "" ).trimmingCharacters( in: .whitespacesAndNewlines )

					RtVars.IsEnableDepthCheck = configs.findBoolBy( Api.NowIP, "DepthCheck:Enable", false, false )
					RtVars.DepthCheckSeconds = configs.findIntBy( Api.NowIP, "DepthCheck:CheckSecs", 15, false )


					RtVars.OffLivingDetectTimes = TimeRange.ParseBy( configs.findStrBy( "", "TempOffLivingDetectTimes", "", false ) )
					if let rangeTime = RtVars.OffLivingDetectTimes.findInRangeBy( dtNow )
					{
						RtVars.CurrentIsOffLivingDetectTime = true
						Log.Debug( "[Api] current time[\( TimeRange.GetIntBy( Date() ) )] is During OffLiving Time[\( rangeTime )]" )
					}
					else
					{
						RtVars.CurrentIsOffLivingDetectTime = false
					}

					RtVars.AdminIds = configs.findStrBy( "", "FeatureAdminStaffIds", "" ).replace( " ", "" ).replace( "Z", "" ).split( separator: "," ).map { Int( $0 ) ?? 999999999 }
					RtVars.AdminValidCode = configs.findStrBy( Api.NowIP, "FeatureAdminValidCode", "" ).replace( " ", "" )

					RtVars.IsUpdated = true

					//------------------------------------------------------------------------
					onSuccess( configs )
			}
		} )
	}

	// 取得configs並轉換為SdkConfigs
	public static func GetSdkConfigs( _ onSuccess: @escaping ( _ configs: SdkConfigs, _ dbConfigs: [dbConfig] ) -> Void )
	{
		if self.NowIP.length <= 0
		{
			Log.Error( "[Api:SdkConfig] get SdkConfigs Failed, Cannot get CurrentIP" )
			return
		}

		GetConfigs
		{
			configs in

			let sdkConfigs = SdkConfigs.shared

			sdkConfigs.ApplyBy( self.NowIP, configs )

			onSuccess( sdkConfigs, configs )
		}
	}

	public static func SendPunchBy( _ id: String, _ uuid: String, _ onSuccess: ( () -> Void )? = nil )
	{
		Log.Debug( "[Api:Punch] sending id[\( id )] uuid[\( uuid )]" )

		if ( id.length <= 0 || uuid.length <= 0 )
		{
			Log.Error( "[Api:Punch] 打卡失敗, 傳送之資料不正確" )
			return
		}


		let body: [String: Any] = [ "staffId": id, "uuid": uuid, "createdAt": Date().toStringBy( format: .full ) ]
		let json = Json( body )

		Api.ExecuteApiBy( { onDone in Api.RequestBy( .POST, "/punch/add", json, onDone ) },
		{
			rep, ret in

			switch ret
			{
				case .no( let ex ):
					Log.Error( "[Api:Punch] 打卡失敗, \( ex.message )" )
				case .ok:
					Log.Debug( "[Api:Punch] 打卡成功, id[\( id )] uuid[\( uuid )]" )
					onSuccess?()
			}
		} )
	}

	public static func SendLogBy( _ body: String, _ onDone: @escaping ( Int, Http.HttpError? ) -> Void )
	{
		Api.ExecuteApiBy( { onDone in Api.RequestBy( .POST, "/log/add", body, onDone ) },
		{
			rep, ret in

			switch ret
			{
				case .no( let ex ):
					onDone( 0, ex )
				case .ok( let rst ):
					let count = Int( rst ) ?? 0
					onDone( count, nil )
			}
		} )
	}

	public static func SendSatisfactionBy( _ score: Int )
	{
		let body: [String: Any] = [ "score": score ]
		let json = Json( body )

		Api.ExecuteApiBy( { onDone in Api.RequestBy( .POST, "/satisfaction/add", json, onDone ) },
		{
			rep, ret in

			switch ret
			{
				case .no( let ex ):
					Log.Error( "[Api:Satisfaction] 傳送失敗, \( ex.message )" )
				case .ok( _ ):
					Log.Debug( "[Api:Satisfaction] 傳送成功" )
			}
		} )
	}

	public static func GetAnnounce( _ onSuccess: @escaping ( [String] ) -> Void )
	{
		Api.ExecuteApiBy( { onDone in Api.RequestBy( .GET, "/announce/all", onDone ) },
		{
			rep, ret in

			switch ret
			{
				case .no( let ex ):
					Log.Error( "[Api:Announce] 取得公告失敗, \( ex.message )" )
					onSuccess( [] )
				case .ok( let body ):
					var messages: [String] = []
					let json = Json.parseBy( body )
					for ( item ) in json.arrayValue
					{
						messages.append( item["content"].stringValue )
					}
					Log.Debug( "[Api:Announce] 取得公告成功, 數量[\( messages.count )]" )
					if ( messages.count <= 0 ) { messages.append( "目前尚無公告" ) }
					onSuccess( messages )
			}
		} )
	}

	public static func SendFeatureAddBy( _ model: IPadFeature, _ onSuccess: @escaping () -> Void, _ onFailed: @escaping ( _ ex: Http.HttpError ) -> Void )
	{
		var body = model.json
		if ( Api.Aes.length > 0 )
		{
			do
			{
				let encoded = try body.encodeAesCbcPadding5CustomBy( Api.Aes ).base64EncodedString()
				body = encoded
			}
			catch
			{
				Log.Error( "[Api:Feature] encode failed, use raw string, \( error )" )
			}
		}

		Api.ExecuteApiBy( { onDone in Api.RequestBy( .POST, "/feature/add", body, onDone ) },
		{
			rep, ret in

			switch ret
			{
				case .no( let ex ):
					onFailed( ex )
				case .ok( _ ):
					onSuccess()
			}
		} )
	}
}

