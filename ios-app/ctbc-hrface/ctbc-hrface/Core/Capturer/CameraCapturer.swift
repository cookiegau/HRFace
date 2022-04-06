import UIKit
import AVFoundation
import Vision
import CtbcCore
#if !arch( x86_64 )
import FaceCore
#endif

class CameraCapturer: Capturer, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureDepthDataOutputDelegate
{
	public static let shared: CameraCapturer = CameraCapturer()
	var shapeLayer = CAShapeLayer()

	var ViewW: Double!
	var ViewH: Double!

	var NowUUIDs: [String] = []

	var NowImageRgb: UIImage?
	var NowImageDepth: UIImage?

	private var previewView: PreviewView!

	let sessionIdentify = AVCaptureSession()
	let sessionForView = AVCaptureSession()

	let outputCaptureIdentify = AVCaptureVideoDataOutput()
	let outputCaptureDepth = AVCaptureDepthDataOutput()

	let outputCaptureForView = AVCaptureVideoDataOutput()

	let queueForBgView = DispatchQueue( label: "queueBgView" )
	let queueForDepth = DispatchQueue( label: "queueDepth" )
	let queueForIdentify = DispatchQueue( label: "queueIdentify" )

	let sessionPreset: AVCaptureSession.Preset = .high;

	//============================================================================================================
	deinit
	{
		NotificationCenter.default.removeObserver( self )
	}

	func InitObserver( _ session: AVCaptureSession )
	{
		NotificationCenter.default.addObserver( self, selector: #selector( OnSessionError ), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: session )
		NotificationCenter.default.addObserver( self, selector: #selector( OnSessionInterrupted ), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: session )
	}

	//============================================================================================================
	@objc func OnSessionError( notification: NSNotification )
	{
		guard let nsEx = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else
		{
			return
		}

		let exAV = AVError( _nsError: nsEx )

		Log.Error( "[session] runtime error, code[\( exAV.code )] ex[\( exAV )]" )

		Log.Debug( "[session] Start Reset CameraCapturer" )
		CameraCapturer.shared.Restart()
		Log.Debug( "[session] Already Restart CameraCapturer via LongPress TimeBox" )
		//ShowAlertBy( "系統訊息", "已經重新啟動相機" )
	}

	@objc func OnSessionInterrupted( notification: NSNotification )
	{
		if let uiv = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
		let code = uiv.integerValue,
		let reason = AVCaptureSession.InterruptionReason( rawValue: code )
		{
			Log.Error( "[session] interrupted, reason[\( reason )]" )

			RecognizeVC.shared.HandleFlowErrorBy( "[App] 相機裝置連接失敗\n\( reason )", Err.Initialize( "[Camera] session was interrputed, \( reason )" ) )
		}
	}

	//============================================================================================================
	public var IsStarted: Bool
	{
		get { return self.sessionIdentify.isRunning }
	}

	//============================================================================================================
	override func InitBy( view: PreviewView? ) throws
	{
		try self.InitBase( view )
	}

	override func Start()
	{
		Async.main
		{
			if !self.sessionIdentify.isRunning { self.sessionIdentify.startRunning() }
			Log.Debug( "[Capturer] Start..." )
		}
	}

	override func Stop()
	{
		Async.main
		{
			if self.sessionIdentify.isRunning { self.sessionIdentify.stopRunning() }
			Log.Debug( "[Capturer] Stop" )
		}
	}

	override func Restart()
	{
		Async.main // restart twice for clear depth camera
		{
			if self.sessionIdentify.isRunning { self.sessionIdentify.stopRunning() }
			self.sessionIdentify.startRunning()
			self.sessionIdentify.stopRunning()
			self.sessionIdentify.startRunning()

			Log.Debug( "[Capturer] Restarted" )
		}
	}

	//============================================================================================================
	public func StartOnceCheckDepthToRestartCamera( _ seconds: TimeInterval )
	{
		_ = Timer.scheduledTimer( withTimeInterval: seconds, repeats: false )
		{
			_ in

			if ( RtVars.PauseReason.length > 0 )
			{
				Log.Warn( "[Capturer] the check run before PauseReason[\( RtVars.PauseReason )]" )
				return
			}

			if ( self.NowImageDepth == nil )
			{
				Log.Warn( "[Capturer] after \( seconds ) seconds, ImageDepth still nil, restart..." )
				self.Restart()
			}
		}
	}

	//============================================================================================================
	func InitBase( _ argView: PreviewView? ) throws
	{
		Log.Debug( "[Capturer] init mode living[\( RtVars.CurrentLivingMode )]" )

		guard let view = argView else
		{
			throw Err.Initialize( "must have arg view for init" )
		}

		previewView = view
		previewView!.session = sessionIdentify

		sessionIdentify.beginConfiguration()
		sessionIdentify.sessionPreset = sessionPreset

		guard let device = AVCaptureDevice.GetAvailableCamera() else
		{
			throw Err.Initialize( "cannot found any available camera" )
		}

		if let deviceInput = device.CreateDeviceInput()
		{
			sessionIdentify.addInput( deviceInput )
		}
		else
		{
			throw Err.Initialize( "cannot create device input from camera" )
		}

		outputCaptureIdentify.alwaysDiscardsLateVideoFrames = true
		outputCaptureIdentify.videoSettings = [ kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA ] as [String: Any]
		outputCaptureIdentify.setSampleBufferDelegate( self, queue: queueForIdentify )
		sessionIdentify.addOutput( outputCaptureIdentify )

		try self.InitDepth()

		self.InitObserver( sessionIdentify )

		self.previewView!.videoPreviewLayer.videoGravity = .resizeAspectFill



		var orientation = AVCaptureVideoOrientation.portrait
		let statusBarOrientation = UIApplication.shared.statusBarOrientation
		if statusBarOrientation != .unknown
		{
			if let videoOrientation = statusBarOrientation.videoOrientation
			{
				orientation = videoOrientation
				self.previewView.videoPreviewLayer.connection!.videoOrientation = orientation
			}
		}

		do
		{
			try self.initForPreviewAndPainter()

			_ = Timer.scheduledTimer( withTimeInterval: self.ProcessDrawLogicTimeInterval, repeats: true ) { ( timer ) in self.ProcessDrawLogic() }

			Log.Debug( "[Capturer] init finish" )
		}
		catch
		{
			RecognizeVC.currentEx = error
			Log.Error( "[Capturer] init failed, \( error.localizedDescription )" )
		}
	}

	func InitDepth() throws
	{
		guard sessionIdentify.canAddOutput( outputCaptureDepth ) else
		{
			throw Err.Initialize( "cannot add DepthOutput" )
		}

		sessionIdentify.addOutput( outputCaptureDepth )
		outputCaptureDepth.setDelegate( self, callbackQueue: queueForDepth )
		outputCaptureDepth.isFilteringEnabled = false
		sessionIdentify.commitConfiguration()

		guard let conn = outputCaptureDepth.connection( with: .depthData ) else
		{
			throw Err.Initialize( "cannot connect to DepthOutput" )
		}
		conn.isEnabled = true
		conn.videoOrientation = AVCaptureVideoOrientation( rawValue: AVCaptureVideoOrientation.portrait.rawValue )!
	}

	var vwDepthImg: UIImageView!
	var vwDebugTxt: BaseLabel!
	var vwDepthTxt: BaseLabel!

	func initForPreviewAndPainter() throws
	{
		guard let device = AVCaptureDevice.GetAvailableCamera() else { throw Err.Initialize( "cannot found any available camera" ) }
		guard let deviceInput = device.CreateDeviceInput() else { throw Err.Initialize( "cannot create DeviceInput from camera" ) }

		if ( sessionForView.canAddInput( deviceInput ) ) { sessionForView.addInput( deviceInput ) }

		let resolution = device.GetResolution()
		outputCaptureForView.videoSettings = [ kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA ] as [String: Any]
		outputCaptureForView.setSampleBufferDelegate( self, queue: queueForBgView )
		sessionForView.addOutput( outputCaptureForView )

		guard let pvView = previewView else { throw Err.Initialize( "cannot get preview view" ) }

		let layer = AVCaptureVideoPreviewLayer( session: sessionForView )
		layer.frame = pvView.frame

		shapeLayer.frame = pvView.frame
		shapeLayer.backgroundColor = UIColor.clear.cgColor

		layer.videoGravity = AVLayerVideoGravity.resizeAspect
		layer.backgroundColor = UIColor.gray.cgColor


		pvView.layer.addSublayer( layer )
		layer.isHidden = true
		pvView.layer.addSublayer( shapeLayer )

		let ratio = resolution.height / resolution.width
		ViewW = Double( RecognizeVC.shared.view.bounds.width ) / Double( resolution.width ) //720 1080
		ViewH = Double( UIScreen.main.bounds.width * ratio ) / Double( resolution.height ) //1280 1920


		//==========================================================================================
		let dw: CGFloat = 180
		let dh: CGFloat = dw * ( UIScreen.main.bounds.height / UIScreen.main.bounds.width )
		vwDepthImg = UIImageView( frame: CGRect( x: 6, y: 120, width: dw, height: dh ) )
		vwDepthImg.setBorderBy( UIColor.red, 2 )
		vwDepthImg.layer.opacity = 0
		pvView.addSubview( vwDepthImg )
		pvView.superview?.bringSubviewToFront( vwDepthImg )
		//------------------------------------
		vwDepthTxt = BaseLabel( frame: CGRect( x: 3, y: 3, width: 40, height: 20 ) )
		vwDepthTxt.setBorderBy( UIColor.black, 2 )
		vwDepthTxt.backgroundColor = .white
		vwDepthTxt.font = UIFont.boldSystemFont( ofSize: 15 )
		vwDepthTxt.textAlignment = .center
		vwDepthImg.addSubview( vwDepthTxt )

		//==========================================================================================
		vwDebugTxt = BaseLabel( frame: CGRect( x: 505, y: ( 790 ), width: 320, height: 220 ) )
		vwDebugTxt.setBorderBy( UIColor.red, 2 )
		vwDebugTxt.layer.backgroundColor = UIColor.white.cgColor
		vwDebugTxt.font = UIFont.boldSystemFont( ofSize: 10 )
		vwDebugTxt.textAlignment = .left
		vwDebugTxt.paddingLeft = 5
		vwDebugTxt.numberOfLines = 100
		vwDebugTxt.layer.opacity = 0
		pvView.addSubview( vwDebugTxt )
		pvView.superview?.superview?.superview?.bringSubviewToFront( vwDebugTxt )
	}

	//============================================================================================================
	func captureOutput( _ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection ) {}

	func captureOutput( _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection )
	{
		if ( RtVars.PauseReason.length > 0 ) { return }

		guard let pixelBuffer = CMSampleBufferGetImageBuffer( sampleBuffer ) else
		{
			Log.Error( "[Capture:Output] create CMSampleBufferGetImageBuffer from sampleBuffer Failed" )
			return
		}

		CVPixelBufferLockBaseAddress( pixelBuffer, .readOnly )
		let baseAddress = CVPixelBufferGetBaseAddress( pixelBuffer )
		let width = CVPixelBufferGetWidth( pixelBuffer )
		let height = CVPixelBufferGetHeight( pixelBuffer )
		let bytesPerRow = CVPixelBufferGetBytesPerRow( pixelBuffer )
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo( rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue )

		guard let context = CGContext( data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue ) else
		{
			Log.Error( "[Capture:Output] create GCContext Failed" )
			return
		}
		guard let cgImage = context.makeImage() else
		{
			Log.Error( "[Capture:Output] GCContext.makeImage Failed" )
			return
		}

		CVPixelBufferUnlockBaseAddress( pixelBuffer, .readOnly )
		connection.videoOrientation = AVCaptureVideoOrientation( rawValue: AVCaptureVideoOrientation.portrait.rawValue )!


		self.NowImageRgb = UIImage( cgImage: cgImage )

		self.CallFaceCoreSdkDetectWithService()
	}

	func depthDataOutput( _ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection )
	{
		if ( RtVars.PauseReason.length > 0 ) { return }

		let deep: AVDepthData = depthData.convertToDepth()
		guard let ciImage = deep.depthDataMap.transformedImage() else
		{
			Log.Error( "[Capture:DepthOutput] depthDataMap.transformedImage failed" )
			return
		}
		let ciContext = CIContext()
		guard let cgi = ciContext.createCGImage( ciImage, from: ciImage.extent ) else
		{
			Log.Error( "[Capture:DepthOutput] ciContext.createCGImage failed" )
			return
		}

		self.NowImageDepth = UIImage( cgImage: cgi )

		if ( self.NowImageDepth == nil )
		{
			Log.Error( "[Capture:DepthOutput] cannot create Image from cgImage" )
		}
		else
		{
			Async.main
			{
				if self.vwDepthImg.layer.opacity > 0
				{
					self.vwDepthImg.image = UIImage( cgImage: cgi )
				}
			}
		}
	}

	//============================================================================================================
	private var countNull = 0

	func CallFaceCoreSdkDetectWithService()
	{
		guard let imgRgb = self.NowImageRgb else
		{
			Log.Warn( "[CallSdk] current ImageRgb is nil, ignore" )
			return
		}

		guard let detector = RecognizeVC.shared.detector else { return }

		detector.setLivingDetect( is_activate: RtVars.CurrentLivingMode )

		//------------------------------------------------------------------------
		// non-living mode
		//------------------------------------------------------------------------
		if ( !RtVars.CurrentLivingMode )
		{
			detector.detectWithService( source_image: imgRgb, draw_face: .no, orientation: .mirror, min_size: SdkConfigs.shared.detectWithService_min_size )
			return
		}

		//------------------------------------------------------------------------
		// living-mode
		//------------------------------------------------------------------------
		queueForDepth.sync
		{
			if let imgDep = self.NowImageDepth
			{
				self.countNull = 0
				detector.detectWithServiceDepth( source_image: imgRgb, depth_image: imgDep, draw_face: .no, orientation: .mirror, min_size: SdkConfigs.shared.detectWithService_min_size )
			}
			else
			{
				self.countNull += 1
				if ( self.countNull >= 3 )
				{
					self.countNull = 0
					Log.Warn( "[CallSdk] the DepthImage is nil, cannot call detectWithServiceDepth" )
				}
			}
		}
	}

	//============================================================================================================
	private let ProcessDrawLogicTimeInterval: TimeInterval = 0.1

	func ProcessDrawLogic()
	{
		if ( RtVars.PauseReason.length > 0 || ( RtVars.CurrentLivingMode && self.NowImageDepth == nil ) )
		{
			RecognizeVC.FDOlds.removeAll()
			RecognizeVC.FDNews.removeAll()

			RecognizeVC.NowImgViews.removeAll()
			RecognizeVC.shared.refreshViews()
			return
		}

		RecognizeVC.FDOlds.removeAll()
		RecognizeVC.FDOlds = RecognizeVC.FDNews
		RecognizeVC.FDNews.removeAll()

		let screenSize = UIScreen.main.bounds.size
		let ratio: Double = Double( screenSize.width / screenSize.height )
		let ratioImgH: Double = 1080 / ratio


		//------------------------------------------------------------------------
		var debugInfo = ""
		debugInfo += "Now Living Mode [ \( RtVars.CurrentLivingMode ) ]\n"
		debugInfo += "Now [\( Date().toString(format: "HH:mm:ss" ) )] IsOffTime[ \( RtVars.CurrentIsOffLivingDetectTime ) ]\n"
		debugInfo += "LastPunch [ \( RtVars.LastPunch?.toString(format: "HH:mm:ss") ?? "---" ) ] Id[ \( RtVars.LastPunchId ?? "---" ) ]\n"

		if let detectInfo = RecognizeVC.shared.detector.detect_info
		{
			var imgH: Double = 0
			if let imgDetect = detectInfo.origin_image
			{
				imgH = Double( imgDetect.size.height )
			}
			let adjustH = ( imgH - ratioImgH ) * 0.75 / 2


			if let faceList = detectInfo.face_list
			{
				debugInfo += "Detect Face Count [ \( faceList.count ) ]\n"

				if ( faceList.count <= 0 )
				{
					RecognizeVC.NowImgViews.removeAll()
				}
				else
				{
					RtVars.LastDetectInfo = Date()
					debugInfo += "\n"

					for info in faceList
					{
						var rect: CGRect = CGRect( x: 0, y: 0, width: 0, height: 0 )
						if var x1 = info.dx1, var x2 = info.dx2, var y1 = info.dy1, var y2 = info.dy2
						{
							x1 = x1 * self.ViewW
							y1 = y1 * self.ViewH
							x2 = x2 * self.ViewW
							y2 = y2 * self.ViewH
							rect = CGRect( x: x1, y: y1 - adjustH, width: x2 - x1, height: ( y2 - y1 ) )
						}

						//------------------------------------------------------------
						if let uuid = info.uuidStr
						{
							self.NowUUIDs.append( uuid )
							if RecognizeVC.NowImgViews[uuid] == nil { RecognizeVC.NowImgViews[uuid] = ViewUtils.makeNewAnimeBy( rect ) }
						}

						//------------------------------------------------------------
						let str = info.json.rawString( .utf8, options: [ .sortedKeys, .prettyPrinted ] ) ?? "---"
						Log.Debug( "[Sdk] detect info[\( info.jsonStr )]" )
						debugInfo += "\( str )\n"

						if let detected = info.is_detect
						{
							// mark
							if detected { RecognizeVC.FDNews.append( FaceDetail( info, rect ) ) }
						}

						if RecognizeVC.FDOlds.count == 0 { RecognizeVC.FDOlds = RecognizeVC.FDNews }
					}
				}
			}
			else
			{
				debugInfo = "Sdk: detect_info.face_list is nil"
			}
		}
		else
		{
			debugInfo = "Sdk: DetectInfo is nil"
		}

		if ( vwDebugTxt.layer.opacity > 0 && debugInfo.length > 0 )
		{
			Async.main { self.vwDebugTxt.text = "\( debugInfo )" }
		}


		//------------------------------------------------------------------------
		let allUUIDs = RecognizeVC.NowImgViews.keys
		for uuid in allUUIDs
		{
			var needRm = true
			for string in self.NowUUIDs
			{
				if uuid == string
				{
					needRm = false
					if let imgV = RecognizeVC.NowImgViews[uuid]
					{
						for fd in RecognizeVC.FDNews
						{
							if let uuid = fd.uuid, uuid == uuid { imgV.frame = fd.frame }
						}
					}
				}
			}

			if ( needRm ) { RecognizeVC.NowImgViews.removeValue( forKey: uuid ) }
		}

		//------------------------------------------------------------------------
		RecognizeVC.shared.refreshViews()
	}
}
