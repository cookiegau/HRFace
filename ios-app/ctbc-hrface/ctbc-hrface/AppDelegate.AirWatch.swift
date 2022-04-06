import Foundation
import CtbcCore
//====================================================================================
// AirWatch
//====================================================================================

//------------------------------------------------------------------------------
// 如果不使用AirWatch, 請啟用這一行, 並將下方全mark, 並移除相關Framework
//------------------------------------------------------------------------------
//extension AppDelegate
//{
//    func StartAirWatch() {}
//    func AirWatchHandleOpenUrl( _ url:URL, _ sourceApplication:String? ) -> Bool { return false }
//    func AirWatchControllerInitialCheck( error: NSError? ) {}
//}


//------------------------------------------------------------------------------
// 如果要使用AirWatch, 請啟用下方, 並將上方mark, 並加入相關Framework
//------------------------------------------------------------------------------
#if !arch(x86_64)
import AWSDK
extension AppDelegate : AWControllerDelegate
{
	func StartAirWatch()
	{
		if let AirWatchSchemeName = AppConfigs.shared.AirWatchSchemeName
		{
			Log.Debug( "[AirWatch] AirWatch SDK Start AWController..." )
			let awController = AWController.clientInstance()
			awController.callbackScheme = AirWatchSchemeName
			awController.delegate = self
			awController.start()
		}
	}

    func AirWatchHandleOpenUrl( _ url:URL, _ sourceApplication:String? ) -> Bool
    {
        let handedBySDKController = AWController.clientInstance().handleOpenURL( url, fromApplication: sourceApplication )
        if handedBySDKController
        {
            Log.Debug( "[AirWatch] Handed over open URL to AWController, url[\( url.absoluteString )]" )
            AWLogInfo( "Handed over open URL to AWController" )
            return true
        }

        Log.Debug( "[AirWatch] not handled  url[\( url.absoluteString )]" )
        return false
    }

    func AirWatchControllerInitialCheck( error: NSError? )
    {
        if error != nil {
            Log.Debug( "[App] AirWatch SDK initial failed: \( String( describing: error) )" )
            AWLogError( "AirWatch SDK initial failed: \( String( describing: error) )" )
            return
        }

        Log.Debug( "[AirWatch] AirWatch SDK Initialize Success" )
        AWLogInfo( "AirWatch SDK initial success" )
    }
}
#endif
