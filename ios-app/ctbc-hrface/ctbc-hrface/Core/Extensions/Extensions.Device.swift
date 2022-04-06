import AVKit


extension AVCaptureDevice
{
	static let defaultUseDevice = AVCaptureDevice.Position.front

	public static func GetAvailableCamera() -> AVCaptureDevice?
	{
		var device: AVCaptureDevice?
		if ( defaultUseDevice == .front )
		{
			if let cameraFront = AVCaptureDevice.default( .builtInTrueDepthCamera, for: AVMediaType.video, position: .front ) { device = cameraFront }
		}
		else
		{
			if let cameraBack = AVCaptureDevice.default( .builtInDualCamera, for: AVMediaType.video, position: .back ) { device = cameraBack }
			else if let backCameraDevice = AVCaptureDevice.default( .builtInWideAngleCamera, for: AVMediaType.video, position: .back ) { device = backCameraDevice }
		}

		// let devices = AVCaptureDevice.DiscoverySession( deviceTypes: [ .builtInWideAngleCamera ], mediaType: AVMediaType.video, position: .front ).devices
		// if let captureDevice = devices.first {}

		return device
	}

	public func GetResolution() -> CGSize
	{
		let desc = self.activeFormat.formatDescription
		let dimensions = CMVideoFormatDescriptionGetDimensions( desc )
		return CGSize( width: CGFloat( dimensions.height ), height: CGFloat( dimensions.width ) )
	}

	public func CreateDeviceInput() -> AVCaptureDeviceInput?
	{
		do
		{
			return try AVCaptureDeviceInput( device: self )
		}
		catch
		{
			return nil
		}
	}
}
