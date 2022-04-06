import AVKit

extension UIInterfaceOrientation
{
	var videoOrientation: AVCaptureVideoOrientation?
	{
		switch self
		{
			case .portrait: return .portrait
			case .portraitUpsideDown: return .portraitUpsideDown
			case .landscapeLeft: return .landscapeLeft
			case .landscapeRight: return .landscapeRight
			default: return nil
		}
	}
}

extension NSNotification.Name
{
	static let WResourcesWillLoadResources = Notification.Name( "WResourcesWillLoadingResources" )
	static let WResourcesInLoadResourcesProgress = Notification.Name( "WResourcesInLoadResourcesProgress" )
	static let WResourcesDidLoadResources = Notification.Name( "WResourcesDidLoadResources" )
}

//============================================================================================================
// for Application Level
//============================================================================================================
