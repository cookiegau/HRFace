import AVFoundation
import CoreData
import Network
import QuartzCore
import UIKit
import Vision

import CtbcCore

#if !arch( x86_64 )
import FaceCore
#endif

let hasCamera = AVCaptureDevice.DiscoverySession( deviceTypes: [ .builtInWideAngleCamera ], mediaType: .video, position: .front ).devices.count > 0

extension RecognizeVC
{
	//==========================================================================================
	func InitializeConfigs() throws
	{
		do
		{
			try ConfigUtils.LoadAppConfig()
			{
				configs in
				Log.Debug( "[App] Local Configs: \( AppConfigs.shared )" )
			}
		}
		catch
		{
			Log.AppendTodayCrashLogBy( "[App] Failed to Load Config, \( error )" )
		}

		Api.SetEndpointBy( AppConfigs.shared.SDK_Service_Endpoint )
		try Api.SetSdkTokenBy( AppConfigs.shared.SDK_Token_Endpoint, AppConfigs.shared.SDK_Token_UserName, AppConfigs.shared.SDK_Token_Password )

		try InitLogHandler()
	}

	func InitLogHandler() throws
	{

		let dir = try Log.GetDirForLogs( "Logs" )

		let names = dir.find( "*.log" ).map { $0.string.replace( dir.string, "" ) }
		Log.Debug( "Local Log Files[\( names.count )] (\( names.joined( separator: "," ) ))" )

		var logsForSend = [ String ]()
		try Log.SetOnIntervalBy( 10 )
		{
			( logs, isCrash ) in

			//========================================================================
			if ( !RtVars.IsUpdated && !isCrash ) { return }

			if ( logs.count >= 1 )
			{
				if ( isCrash || !RtVars.IsAllowServerLog )
				{
					let msgs = logs.getBy { $0.JoinLines( { $0.lv.rawValue >= Log.Level.Error.rawValue } ) }
					if ( msgs.length >= 1 ) { logsForSend.append( msgs ) }
				}
				else
				{
					if ( !RtVars.IsServerLogFullMode )
					{
						let msgs = logs.getBy { $0.JoinLines( { $0.lv.rawValue >= Log.Level.Info.rawValue } ) }
						if ( msgs.length >= 1 ) { logsForSend.append( msgs ) }
					}
					else
					{
						let msgs = logs.getBy { $0.JoinLines( { $0.lv.rawValue >= Log.Level.Debug.rawValue } ) }
						if ( msgs.length >= 1 ) { logsForSend.append( msgs ) }
					}
				}

				var canWrite = false
				if ( isCrash ) { canWrite = true }
				if ( RtVars.IsUpdated && RtVars.IsAllowLocalLog ) { canWrite = true }

				if ( canWrite )
				{
					do
					{
						let msgs = logs.getBy { $0.JoinLines() }

						print( "[Log] writing[ \( msgs.count ) ] isCrash[\( isCrash )] AllowLocalLog[ \( RtVars.IsAllowLocalLog ) ] msgs:\( msgs )" )

						let nameToday = "\( Date().toString( format: "yyyyMMdd" ) ).log"
						let pathToday = dir + nameToday
						try pathToday.append( "\( msgs )\n" )
					}
					catch
					{
						Log.Error( "[Log] write local log failed, \( error )" )
					}
				}

				logs.removeAll()
			}
			//========================================================================
			if ( Api.IsAvailable && logsForSend.count >= 1 )
			{
				let messages = logsForSend.joined( separator: "\n" )
				logsForSend.removeAll()

				Api.SendLogBy( messages )
				{
					( count, httpEx ) in

					if let ex = httpEx
					{
						Log.Error( "[Api] SendLog failed, code[\( ex.code )] message[\( ex.message )] error[\( ex.error )] logs[\( messages )]" )
						//logsForSend.append( messages ) // 如果需要重送
					}
				}

				if ( isCrash ) { sleep( 1 ) }
			}

			//========================================================================
			// Warn: the App under AirWatch Control will Crash in Production Env
			//       waiting VMware official tech support to resolve this issue
			//========================================================================
//			if ( !isCrash && RecognizeVC.IsAllowLocalLog )
//			{
//				let checkSecs = Date().timeIntervalSince( dtChecked )
//				if ( checkSecs >= ( 60 * 30.0 ) )
//				{
//					let today = Date()
//					let files = dir.find( "*.log" )
//					if ( files.count >= 2 )
//					{
//						for file in files
//						{
//							if let date = file.dateModified
//							{
//								let days = Int( floor( today.timeIntervalSince( date ) / 60 / 60 / 24 ) )
//								if ( days >= AppConfigs.shared.LogsKeepDays )
//								{
//									Log.Trace( "[Logs] delete outdated file[\( file.url.lastPathComponent )] (\( days ) days)" )
//									do { try file.delete() }
//									catch
//									{
//										Log.Error( "[Logs] delete outdated log failed, file[\( file.url.lastPathComponent )], \( error.localizedDescription )" )
//									}
//								}
//							}
//						}
//					}
//					dtChecked = today
//				}
//			}
		}
	}

	//==========================================================================================
	func InitializeStart()
	{
		self.ShowPopupMaintain( "...初始化中...", false )

		Log.Debug( "[App] detecting network status..." )
		let ipv4 = NetUtils.GetAvailableIPv4()

		guard let ip = ipv4 else
		{
			self.ShowPopupMaintain( "初始化失敗\n無法取得IP" )
			_ = Timer.scheduledTimer( withTimeInterval: 5.0, repeats: false ) { _ in self.InitializeStart() }
			return
		}

		Log.Debug( "[App] current IP: \( ip )" )
		Api.SetPositionIP( ip )
		Api.StartAutoCheck()
		self.ShowPopupMaintain( "本地IP: \( ip )\n服務連線中...", false )

		self.startAutoRetryConnect()
	}

	func InitSdk( _ configs: SdkConfigs, _ onDone: @escaping ( _ result: Result<Bool, Error> ) -> Void )
	{
		Log.Debug( "[SDK] init..." )

		detector = CTBCFaceDetection()
		detector.delegate = self

		detector.setModelType( model_type: .normal )

		let currentIp = NetUtils.GetAvailableIPv4() ?? "no-ip"
		detector.setDeviceID( id: currentIp )

		//------------------------------------------------------------------------------
		// configs from api
		//------------------------------------------------------------------------------
		detector.setHoldSecond( threshold: configs.holdSecond )
		detector.setMatchCount( threshold: configs.matchCount )
		detector.setNameCount( threshold: configs.nameCount )
		detector.setLivingDetect( is_activate: configs.livingDetect )
		detector.setLivingCount( threshold: configs.livingCount )
		detector.setSmileDetect( is_activate: configs.smileDetect )
		detector.setLivingThreshold( threshold: configs.livingThreshold )
		detector.checkSmile( check: configs.checkSmile )
		detector.setTrackingMatch( is_tracking: configs.trackingMatch_isTracking, threshold: configs.trackingMatch_threshold )

		detector.setRequestTimeout( sec: configs.requestTimeout )
		detector.setTempCount( threshold: configs.tempCount )

		detector.setHappyCount( threshold: configs.happyCount )
		detector.setHappyThreshold( threshold: configs.happyThreshold )

		detector.setLogUrl( send_log: true, url: AppConfigs.shared.SDK_Log_Url )
		detector.setLicenseUrl( url: AppConfigs.shared.SDK_License_Endpoint )
		detector.setServiceUrl( url: AppConfigs.shared.SDK_Service_Endpoint )
		detector.setAPITokenInfo( url: AppConfigs.shared.SDK_Token_Endpoint, user_name: AppConfigs.shared.SDK_Token_UserName, password: AppConfigs.shared.SDK_Token_Password )

		detector.checkAPIToken( complete:
		{
			( msg, success ) in

			if ( success == false )
			{
				Log.Error( "[SDK] check ApiToken Failed, \( msg )" );
				self.ShowPopupMaintain( "SDK初始化失敗\nToken異常\nmsg[\( msg )]" )

				onDone( .failure( Err.Initialize( "check ApiToken Failed, \( msg )" ) ) )
				return;
			}

			Log.Debug( "[SDK] Token validated" )
			self.detector.checkLicense( key: AppConfigs.shared.SDK_License_Key, complete:
			{
				( msg, success ) in

				if ( !success )
				{
					Log.Error( "[SDK] check License failed, \( msg )" )
					self.ShowPopupMaintain( "Sdk驗證失敗\nmsg[\( msg )]" )
					onDone( .failure( Err.Initialize( "check License Failed, \( msg )" ) ) )
					return
				}

				Log.Debug( "[SDK] init success, ServiceEndpoint[\( AppConfigs.shared.SDK_Service_Endpoint )]" )
				onDone( .success( true ) )
			} )
		} )
	}

	func OnInitSdkFinished()
	{
		if ( !hasCamera )
		{
#if targetEnvironment( simulator )
			Log.Error( "[SDK] simulator skip init Camera" )
#else
			self.HandleFlowErrorBy( "初始化失敗,\n目前裝置不支援相機", Err.Initialize( "[App] current device cannot found Camera" ) )
#endif
			return
		}

		//------------------------------------------------------------------------
		let w = UIScreen.main.bounds.width
		let h = UIScreen.main.bounds.height

		//let availableCamera = AVCaptureDevice.GetAvailableCamera()
		//guard let device = availableCamera else
		//{
		//self.HandleFlowErrorBy( "初始化失敗,\n請確認相機狀態", Err.Initialize( "[App] Init failed, Not Available Camera Device" ) )
		//return
		//}

		//let resolution = device.GetResolution()
		//let ratio = resolution.height / resolution.width
		//let hr = w * ratio
		//Log.Debug( "[App] Init CameraView by w[\( w )] h[\( h )] ratioH[\( hr )]" )

		self.viewFace.frame = CGRect( x: 0, y: 0, width: w, height: h )
	}

	//============================================================================================================
	func InitCapture()
	{
		if ( IsInitialized )
		{
			Log.Warn( "[App] cannot init Capture twice" )
			ShowPopupMaintain( "錯誤的操作,\n無法再次啟動Capture" )
			return
		}

		AVCaptureDevice.requestAccess( for: AVMediaType.video )
		{
			isSuccess in

			if ( !isSuccess )
			{
				let pop = UIAlertController( title: "提醒", message: "請啟用相機權限", preferredStyle: .alert )
				pop.addAction( UIAlertAction( title: "確認", style: .default, handler:
				{
					( action ) in
					UIApplication.shared.open( URL( string: UIApplication.openSettingsURLString )! )
					pop.dismiss( animated: true, completion: { exit( 0 ) } )
				} ) )

				self.present( pop, animated: true )

				return
			}

			self.IsInitialized = true

			Async.main
			{
				do
				{
					try CameraCapturer.shared.InitBy( view: self.previewView )
					CameraCapturer.shared.Restart()
					CameraCapturer.shared.StartOnceCheckDepthToRestartCamera( 2 )

					self.viewBg.fadeOut( 1 )
				}
				catch
				{
					self.HandleFlowErrorBy( "啟動相機失敗,\n\( error.localizedDescription )", Err.Initialize( "[App] start CameraCapturer failed, \( error.localizedDescription )" ) )
				}
			}
		}
	}

	func StartConnectionChecker()
	{
		let action: IAction =
		{
			let dtS = Date()
			Api.HtbtBy
			{
				rep, ex in
				if let ex = ex
				{
					RtVars.PauseReason = "CheckerFailed"
					self.ShowPopupMaintain( "系統連線中" )
					Log.Error( "[Checker] connection lost, code[\( ex.code )] message[\( ex.message )] error[\( ex.error )] StartDate[\( dtS )]" )
					return
				}

				Log.Debug( "[Checker] htbt success, get configs for IP[\( Api.NowIP )]" )
				Api.GetConfigs
				{
					( configs ) in

					RecognizeVC.OnButtonStateChanged()

					let msg = RtVars.MaintainMessage
					if ( msg.length <= 0 )
					{
						if ( RtVars.PauseReason.length > 0 )
						{
							Log.Debug( "[Checker] leaving MaintainScreen..." )
							RtVars.PauseReason = ""

							if let ex = RecognizeVC.currentEx
							{
								Log.Warn( "[Checker] previous has Error: \( ex )" )
							}
						}
						self.DismissPopupMaintain()
					}
					else
					{
						if ( RtVars.PauseReason.length <= 0 )
						{
							Log.Debug( "[Checker] get MaintainMessage(\( msg.length ))[\( msg )] into MaintainScreen..." )
							RtVars.PauseReason = "Maintaining:\( msg )"
						}

						self.ShowPopupMaintain( msg )
					}
				}
			}
		}

		action()
		TimerMaintainChecker = Timer.scheduledTimer( withTimeInterval: 15.0, repeats: true ) { _ in action() }
	}
}
