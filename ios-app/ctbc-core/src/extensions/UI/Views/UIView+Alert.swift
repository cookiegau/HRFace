import Foundation
import UIKit

extension UIView
{
	public func ShowAlertBy( _ title: String, _ msg: String, _ onOK: IAction? = nil )
	{
		Async.main
		{
			let controller = UIAlertController( title: title, message: msg, preferredStyle: .alert )
			let okAction = UIAlertAction( title: "確認", style: .default, handler:
			{
				( _ ) in
				if let action = onOK { action() }
			} )
			controller.addAction( okAction )

			self.TopVC?.present( controller, animated: true, completion: nil )
		}
	}

	public func ShowAlertYesNoBy( _ title: String, _ msg: String, _ onOK: @escaping () -> Void )
	{
		let alert = UIAlertController( title: title, message: msg, preferredStyle: .alert )
		let okAction = UIAlertAction( title: "確認", style: .default )
		{
			( _ ) in
			onOK()
		}
		alert.addAction( okAction )

		let cancelAction = UIAlertAction( title: "取消", style: .cancel, handler: nil )
		alert.addAction( cancelAction )

		self.TopVC?.present( alert, animated: true, completion: nil )
	}

	public func ShowAlertToGetTextBy( _ title: String, _ msg: String, _ needCancel: Bool = true, _ onOK: @escaping ( _ txt: String? ) -> Void )
	{
		let alert = UIAlertController( title: title, message: msg, preferredStyle: .alert )

		alert.addTextField
		{ ( box ) in
			//textField.text = "預設文字"
		}

		if ( needCancel )
		{
			let cancelAction = UIAlertAction( title: "取消", style: .cancel, handler: nil )
			alert.addAction( cancelAction )
		}

		alert.addAction( UIAlertAction( title: "確認", style: .default, handler:
		{
			[weak alert] ( _ ) in
			if let textField = alert?.textFields![0] { onOK( textField.text ) }
		} ) )

		self.TopVC?.present( alert, animated: true, completion: nil )
	}
}
