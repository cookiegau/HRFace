import Foundation
import UIKit
import CtbcCore

@IBDesignable
public class BaseButton: UIButton
{
	var IsRunning: Bool = false
	var IsCanFire: Bool = true

	var OnClick: IAction?

	@IBInspectable var IsInCircle: Bool = false
	{
		didSet
		{
			if IsInCircle == false { return }
			self.layer.cornerRadius = min( bounds.width, bounds.height ) / 2
			self.layer.masksToBounds = true
		}
	}

	@IBInspectable var radius: CGFloat = 0
	{
		didSet
		{
			self.layer.cornerRadius = radius
			self.layer.masksToBounds = true
		}
	}

	@IBInspectable var borderWidth: CGFloat = 0
	{
		didSet { self.layer.borderWidth = self.borderWidth }
	}

	@IBInspectable var borderColor: UIColor? = nil
	{
		didSet { self.layer.borderColor = self.borderColor?.cgColor }
	}


	init( title: String )
	{
		super.init( frame: CGRect.zero )
		self.setTitle( title, for: UIControl.State() )
		self.sizeToFit()

		setup()
	}

	init( attributedString: NSAttributedString )
	{
		super.init( frame: CGRect.zero )
		self.setAttributedTitle( attributedString, for: UIControl.State() )
		self.sizeToFit()

		setup()
	}

	init( imageName: String )
	{
		super.init( frame: CGRect.zero )

		if let image = UIImage( named: imageName )
		{
			self.setImage( image, for: UIControl.State() )
			self.frame = CGRect( x: 0, y: 0, width: image.size.width, height: image.size.height )
		}

		setup()
	}

	required init?( coder aDecoder: NSCoder )
	{
		super.init( coder: aDecoder )
		setup()
	}

	override init( frame: CGRect )
	{
		super.init( frame: frame )
		setup()
	}

	func setup()
	{
		self.addTarget( self, action: #selector( BaseButton.onPressed(_:) ), for: .touchDown )
	}

	@objc func onPressed( _ btn: UIButton )
	{
		if self.IsRunning || !self.IsCanFire { return }
		if let callback = OnClick { callback() }
	}
}
