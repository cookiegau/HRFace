import Foundation
import UIKit

extension UIView
{
	public func fadeIn( _ seconds: TimeInterval = 1.0 ){ fadeTo( seconds, 1.0 ) }
	public func fadeOut( _ seconds: TimeInterval = 1.0 ){ fadeTo( seconds, 0.0 ) }
	
	public func fadeTo( _ seconds: TimeInterval = 1.0, _ opacity: CGFloat )
	{
		UIView.animate( withDuration: seconds, animations: { self.alpha = opacity } )
	}
	
	public func animateBy( _ duration: TimeInterval, _ action: @escaping () -> Void )
	{
		let actAnime = { UIView.animate(withDuration: duration, animations: action ) }
		if( Thread.isMainThread )
		{
			actAnime()
		}
		else
		{
			Async.main { actAnime() }
		}
	}
}
