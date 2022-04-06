import UIKit
import CoreData
import CtbcCore

let viewW = UIScreen.main.bounds.width
let viewH = UIScreen.main.bounds.height

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?

	func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool
	{
		NSSetUncaughtExceptionHandler
		{
			ex in
			Log.Fatal( "[App:UncaughtException] name[\( ex.name )] ex: \( ex )\n" )
			Log.TriggerInterval( true )
		}

		signal(SIGABRT) { code in Log.HandleSignalBy( code, "SIGABRT" ) }
		signal(SIGILL) { code in Log.HandleSignalBy( code, "SIGILL" ) }
		signal(SIGSEGV) { code in Log.HandleSignalBy( code, "SIGSEGV" ) }
		signal(SIGFPE) { code in Log.HandleSignalBy( code, "SIGFPE" ) }
		signal(SIGBUS) { code in Log.HandleSignalBy( code, "SIGBUS" ) }
		signal(SIGPIPE) { code in Log.HandleSignalBy( code, "SIGPIPE" ) }
		signal(SIGTRAP) { code in Log.HandleSignalBy( code, "SIGTRAP" ) }

		self.window = UIWindow( frame: UIScreen.main.bounds )
		self.window!.rootViewController = RecognizeVC.shared
		self.window!.makeKeyAndVisible()

		self.StartAirWatch() //setting please follow AppDelegate.AirWatch.swift

		return true
	}
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool
    {
        Log.Debug( "[OpenURL] url[\( url.absoluteString )] options: \( options )" )
        return self.AirWatchHandleOpenUrl( url, nil ) //setting please follow AppDelegate.AirWatch.swift
    }
    func application( _ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any ) -> Bool
    {
        // In the SDK example, it will be called through here, but our app is called through above delegate
        Log.Debug( "[OpenURL] sourceApplication[\( sourceApplication ?? "non-src-app" )] url[\( url.absoluteString )]" )
        return self.AirWatchHandleOpenUrl( url, sourceApplication ) //setting please follow AppDelegate.AirWatch.swift
    }

	func applicationWillResignActive( _ application: UIApplication )
    {
        UIApplication.shared.isIdleTimerDisabled = true
    }
	func applicationDidEnterBackground( _ application: UIApplication )
	{
		Log.Info( "[App] Enter Background" )
		Log.TriggerInterval()
		//exit(0)
	}
	func applicationWillEnterForeground( _ application: UIApplication ) {}
	func applicationDidBecomeActive( _ application: UIApplication ) {}
	func applicationWillTerminate( _ application: UIApplication )
	{
		Log.Info( "[App] Enter Terminate" )
		Log.TriggerInterval()
		//exit(0)
	}

    func controllerDidFinishInitialCheck( error: NSError? )
    {
        self.AirWatchControllerInitialCheck( error: error ) //setting please follow AppDelegate.AirWatch.swift
    }
}



//====================================================================================
// Release Mode
//====================================================================================
#if RELEASE
func print( items: Any..., separator: String = " ", terminator: String = "\n" ) {}
#endif
