#if arch( x86_64 )
//======================================================================================================
// mock framework for AirWatch
//======================================================================================================
import AVFoundation
import UIKit

public func AWLogError( _ msg: String ){}
public func AWLogInfo( _ msg: String ){}

public class AWController
{
	public static func clientInstance() -> AWController
	{
		return AWController()
	}

	init() {

	}

	public var callbackScheme: String = ""
	public var delegate: UIApplicationDelegate?

	public func start(){}
}


@objc(AWSDKDelegate) public protocol AWControllerDelegate : AnyObject
{
    @objc(initialCheckDoneWithError:) func controllerDidFinishInitialCheck(error: NSError?)

    @objc(completedVerificationWithServer:error:) optional func controllerDidCompleteVerificationWithServer(success: Bool, error: NSError?)


    @objc(userChanged) optional func controllerDidDetectUserChange()

    @objc(wipe) optional func controllerDidWipeCurrentUserData()

    @objc(willLock) optional func controllerWillPromptForPasscode()

    @objc(lock) optional func controllerDidLockDataAccess()

    @objc(unlock) optional func controllerDidUnlockDataAccess()


    @objc(resumeNetworkActivity) optional func applicationCanResumeNetworkActivity()


    @objc(didStartServerTrustValidationOnHost:request:) optional func controllerDidStartServerTrustValidation(host: String, request: URLRequest?)

    @objc(didFailServerTrustValidationOnHost:request:) optional func controllerDidFailServerTrustValidation(host: String, request: URLRequest?)

    @objc(didCompletelServerTrustValidationOnHost:request:allowingConnection:) optional func controllerDidCompleteServerTrustValidation(host: String, request: URLRequest?, allowingConnection: Bool)

    @objc(didFinishPollingForPendingCertificateIssued:error:) optional func controllerDidFinishPollingForPendingCertificate(certificateIssued: Bool, error: NSError?)
}


#endif
