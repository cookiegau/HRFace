import UIKit
import Network

import CtbcCore

class BaseVC: UIViewController
{
	init()
	{
		//print( "[BaseUIVC] init \( type( of: self ) )" )
		super.init( nibName: "\( type( of: self ) )", bundle: nil )
	}

	required init?( coder aDecoder: NSCoder ) { super.init( coder: aDecoder ) }

	override init( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? )
	{
		let nibName = ( nibNameOrNil != nil ) ? nibNameOrNil! : "\( type( of: self ) )"

		//print( "[BaseUIVC] init nib:\( nibName )" )
		super.init( nibName: nibName, bundle: nibBundleOrNil )
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()
	}

	override var canBecomeFirstResponder: Bool
	{
		return true
	}

	@objc func dismissKeyboard()
	{
		self.becomeFirstResponder()
		self.resignFirstResponder()
	}
}

extension BaseVC
{
	func PresentBy( _ uvc: UIViewController, _ animated: Bool = true )
	{
		guard let topVC = self.view.TopVC else
		{
			Log.Error( "[UI] cannot found top VC" )
			self.view.ShowAlertBy( "系統訊息", "無法找到頂層VC, 無法顯示" )
			return
		}

		topVC.present( uvc, animated: animated, completion: nil )
	}

	func ShowPopupNewBy( _ mode: PopupVC.Mode )
	{
		DispatchQueue.main.async
		{
			let pop = PopupVC()
			pop.mode = mode
			pop.modalPresentationStyle = .custom

			self.PresentBy( pop )
		}
	}

	func DismissPopupMaintain() { ShowPopupMaintain() }

	func ShowPopupMaintain( _ msg: String? = nil, _ animated: Bool = true )
	{
		let pop = PopupVC.shared
		if let message = msg
		{
			Async.main
			{
				pop.mode = .maintain
				pop.modalPresentationStyle = .custom
				pop.maintainMessage = "\( message )"

				if ( pop.presentationController == nil && pop.presentingViewController == nil )
				{
					self.PresentBy( pop )
				}
			}
		}
		else
		{
			Async.main
			{
				pop.dismiss( animated: true )
			}
		}
	}

	func InitInternetChecker()
	{
		let pop = PopupVC()
		pop.mode = .maintain
		pop.modalPresentationStyle = .custom
		PresentBy( pop )

		let nwMonitor = NWPathMonitor()
		nwMonitor.pathUpdateHandler =
		{
			path in
			DispatchQueue.main.async
			{
				if path.status == .satisfied
				{
					pop.dismiss( animated: true, completion: nil )
				}
				else
				{
					if ( pop.presentationController == nil && pop.presentingViewController == nil )
					{
						self.PresentBy( pop )
					}
				}
			}
		}
		nwMonitor.start( queue: DispatchQueue.global() )
	}
}
