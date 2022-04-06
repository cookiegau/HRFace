import UIKit
import Vision
import AVFoundation

class PreviewView: UIView
{
	private var maskLayer = [ CAShapeLayer ]()

	var videoPreviewLayer: AVCaptureVideoPreviewLayer
	{
		return layer as! AVCaptureVideoPreviewLayer
	}
	var session: AVCaptureSession?
	{
		get { return videoPreviewLayer.session }
		set { videoPreviewLayer.session = newValue }
	}
	override class var layerClass: AnyClass
	{
		return AVCaptureVideoPreviewLayer.self
	}
}
