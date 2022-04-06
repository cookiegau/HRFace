import Foundation
import UIKit

extension UIApplication
{
	// 修復 iOS>=13 取statusBar會出錯的異常
	// UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
	var statusBarUIView: UIView?
	{
		if #available( iOS 13.0, * )
		{
			let tag = 38482458385
			if let statusBar = self.keyWindow?.viewWithTag( tag )
			{
				return statusBar
			}
			else
			{
				let statusBarView = UIView( frame: UIApplication.shared.statusBarFrame )
				statusBarView.tag = tag

				self.keyWindow?.addSubview( statusBarView )
				return statusBarView
			}
		}
		else
		{
			if responds( to: Selector( ( "statusBar" ) ) ) { return value( forKey: "statusBar" ) as? UIView }
		}
		return nil
	}
}
