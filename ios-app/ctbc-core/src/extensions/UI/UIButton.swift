import Foundation
import UIKit

extension UIButton
{
	typealias OnClick = () -> Void
	static var dicActions: [UIButton: OnClick] = [:]

	private func actionHandler( action: ( () -> Void )? = nil )
	{
		if ( action != nil ) { UIButton.dicActions[self] = action }
		else
		{
			if let act = UIButton.dicActions[self] { act() }
			else
			{
				Log.Warn( "[action] not action for trigger" )
			}
		}
	}

	@objc private func triggerActionHandler()
	{
		self.actionHandler()
	}

	public func actionHandler( controlEvents control: UIControl.Event, ForAction action: @escaping () -> Void )
	{
		self.actionHandler( action: action )
		self.addTarget( self, action: #selector( triggerActionHandler ), for: control )
	}
}
