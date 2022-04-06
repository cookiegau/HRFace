import Foundation
import UIKit

@IBDesignable
public class BaseImage: UIImageView
{
	var IsRunning: Bool = false
	var IsCanFire: Bool = true
	
	var tapGesture: UITapGestureRecognizer?
	var OnClick: ( () -> Void )?
	{
		didSet
		{
			self.isUserInteractionEnabled = true
			if ( tapGesture == nil )
			{
				tapGesture = UITapGestureRecognizer( target: self, action: #selector( BaseImage.onPressed ) )
				self.addGestureRecognizer( tapGesture! )
			}
		}
	}
	
	@IBInspectable var IsIncircle: Bool = false
	{
		didSet
		{
			if IsIncircle == false { return }

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
		self.addObserver( self, forKeyPath: "bounds", options: [], context: nil )
	}

	@objc func onPressed()
	{
		if self.IsRunning || !self.IsCanFire { return }
		if let cb = OnClick { cb() }
	}

	override public func observeValue( forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer? )
	{
		if keyPath == "bounds"
		{
			if IsIncircle == true
			{
				self.layer.cornerRadius = min( bounds.width, bounds.height ) / 2
				self.layer.masksToBounds = true
			}
		}
	}
}
