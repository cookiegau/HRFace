import Foundation
import UIKit
import CtbcCore

@IBDesignable
public class BaseLabel: UILabel
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
		self.text = title
		self.sizeToFit()
		setup()
	}

	init( attributedString: NSAttributedString )
	{
		super.init( frame: CGRect.zero )
		self.attributedText = attributedString
		self.sizeToFit()
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
		self.isUserInteractionEnabled = true
		let tap = UITapGestureRecognizer( target: self, action: #selector( BaseLabel.onPressed(_:) ) )
		self.addGestureRecognizer( tap )
	}

	@objc func onPressed( _ btn: UIButton )
	{
		if self.IsRunning || !self.IsCanFire { return }
		if let callback = OnClick { callback() }
	}

	private var padding = UIEdgeInsets.zero

	@IBInspectable public var paddingLeft: CGFloat
	{
		get { return padding.left }
		set { padding.left = newValue }
	}

	@IBInspectable public var paddingRight: CGFloat
	{
		get { return padding.right }
		set { padding.right = newValue }
	}

	@IBInspectable public var paddingTop: CGFloat
	{
		get { return padding.top }
		set { padding.top = newValue }
	}

	@IBInspectable public var paddingBottom: CGFloat
	{
		get { return padding.bottom }
		set { padding.bottom = newValue }
	}

	override public func drawText( in rect: CGRect )
	{
		super.drawText( in: rect.inset( by: padding ) )
	}

	override public func textRect( forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int ) -> CGRect
	{
		let insets = self.padding
		var rect = super.textRect( forBounds: bounds.inset( by: insets ), limitedToNumberOfLines: numberOfLines )
		rect.origin.x -= insets.left
		rect.origin.y -= insets.top
		rect.size.width += ( insets.left + insets.right )
		rect.size.height += ( insets.top + insets.bottom )
		return rect
	}
}
