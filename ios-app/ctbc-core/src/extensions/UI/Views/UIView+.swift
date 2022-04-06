import Foundation
import UIKit

extension UIView
{
	public var TopVC: UIViewController?
	{
		var topVC = UIApplication.shared.keyWindow?.rootViewController
		while let presentedViewController = topVC?.presentedViewController { topVC = presentedViewController }

		if topVC == nil
		{
			Log.Debug( "[UIView] cannot found top VC, try finding..." )
			if let topWindow = UIApplication.shared.windows.first( where: { $0.rootViewController != nil } )
			{
				topVC = topWindow.rootViewController
			}
			else
			{
				Log.Warn( "[UIView] cannot found top VC" )
			}
		}

		return topVC
	}
}
