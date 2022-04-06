import AVFoundation
import UIKit
import Vision

enum CaptureStatus
{
	case captured
}

enum CaptureError : Error
{
	case InitFailed( _ msg: String )
}

extension CaptureError
{
	var message: String?
	{
		get
		{
			if case let .InitFailed( msg ) = self { return msg }
			return nil
		}
	}
}

protocol ICapture
{
	func InitBy( view: PreviewView? ) throws
	func Start()
	func Stop()
	func Restart()
}

class Capturer: NSObject, ICapture
{
	var image: UIImage?

	public func InitBy( view: PreviewView? ) throws {}

	public func Start() {}
	public func Stop() {}
	public func Restart() {}
}
