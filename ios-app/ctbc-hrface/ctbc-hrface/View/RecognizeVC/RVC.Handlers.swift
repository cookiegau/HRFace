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

extension RecognizeVC
{
	//==========================================================================================
	func startAutoRetryConnect()
	{
		//Log.Debug( "[Api] start auto retry connection..." )
		tryConnectOnFailedHandleBy
		{
			ex in
			Log.Warn( "[Api] Connect Failed,[\( Api.HasToken )] \( ex.message )" )
			self.startCountdownToRetryBy( 6 )
		}
	}

	func startCountdownToRetryBy( _ seconds: Int = 61 )
	{
		var count = seconds

		_ = Timer.scheduledTimer( withTimeInterval: 1, repeats: true )
		{
			timerCD in

			if ( count > 0 )
			{
				count -= 1
				Log.Warn( "[Api] connect failed, wait \( count ) seconds to retry..." )
				self.ShowPopupMaintain( "無法連線至服務\n等待\( count )秒後重試" )
			}
			else
			{
				timerCD.invalidate()
				self.startAutoRetryConnect()
			}
		}
	}

	func tryConnectOnFailedHandleBy( _ onFailed: @escaping ( Http.HttpError ) -> Void )
	{
		Api.HtbtBy
		{
			rep, ex in

			if let ex = ex
			{
				onFailed( ex )
				return
			}

			Api.GetSdkConfigs
			{
				( sdkConfigs, dbConfigs ) in

				Log.Debug( "[App] Service connected, Sdk Configs: \( sdkConfigs )" )
				self.ShowPopupMaintain( "服務連線成功...\n進行SDK初始化..." )

				RtVars.IsAllowLocalLog = dbConfigs.findBoolBy( Api.NowIP, "AllowLocalLog", true )

				let startInitCapture =
				{
					self.StartConnectionChecker()
					self.OnInitSdkFinished()
					self.DismissPopupMaintain()
					Async.main
					{
						self.InitCapture()
					}
				}

#if targetEnvironment( simulator )
				Log.Warn( "[App] simulator skip init sdk" )
				startInitCapture()
#else
				self.InitSdk( sdkConfigs )
				{
					result in

					switch ( result )
					{
						case let .failure( ex ):
							Log.Error( "[App] init sdk failed, \( ex.localizedDescription )" )
						case .success( _ ):
							startInitCapture()
					}
				}
#endif
			}
		}
	}

	func HandleFlowErrorBy( _ displayMessage: String, _ ex: Error? = nil, _ codeFile: String = #file, _ codeLine: Int = #line )
	{
		if let nowEx = ex
		{
			var msg = nowEx.localizedDescription
			if ( codeFile.length >= 1 ) { msg += "( \( codeFile ): \( codeLine ) )" }

			Log.Error( msg )
			RecognizeVC.currentEx = nowEx
		}
		self.ShowPopupMaintain( displayMessage )
	}
}
