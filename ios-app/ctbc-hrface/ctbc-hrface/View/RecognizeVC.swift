import AVFoundation
import CoreData
import Network
import QuartzCore
import UIKit
import Vision

import CtbcCore

#if !arch( x86_64 )
import FaceCore
#endif

class RecognizeVC: BaseVC
{
	public static let shared: RecognizeVC = RecognizeVC()

	@IBOutlet weak var previewView: PreviewView!

	var IsInitialized = false

	var configs: SdkConfigs!
	var detector: CTBCFaceDetection!
	var TimerMaintainChecker: Timer!
	static var currentEx: Error?

	var viewFace: UIImageView!
	var viewBg: UIImageView!

	static var btnAnnounce: UIButton!
	static var btnSatisfaction: UIButton!
	static var btnFeatureAdmin: UIButton!

	//------------------------------------
	static var NowImgViews: [String: UIImageView] = [:] //uuid: UIImageView

	static var FDNews: [FaceDetail] = []
	static var FDOlds: [FaceDetail] = []

	public static var CurrentFaceDetail: FaceDetail?
	{
		get
		{
			if ( FDNews.count >= 2 ) { return nil }
			if ( FDNews.count <= 0 ) { return nil }
			let fd = FDNews[0]
			return fd
		}
	}

	override func viewWillAppear( _ animated: Bool )
	{
		super.viewWillAppear( animated )
		self.navigationController?.setNavigationBarHidden( true, animated: false )
	}

	override func viewDidAppear( _ animated: Bool )
	{
		super.viewDidAppear( animated )
	}

	override func viewWillDisappear( _ animated: Bool )
	{
		super.viewWillDisappear( animated )
		self.navigationController?.setNavigationBarHidden( false, animated: true )
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()

		let txtVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "---"

		Log.Info( "[App] Start, iOS[\( UIDevice.current.systemVersion )] App[\( txtVer )]" )
		self.InitializeViews()

		RecognizeVC.shared.ShowPopupMaintain( "...初始化SDK...", false )
	}

	public static func OnButtonStateChanged()
	{
		if ( RtVars.IsDisableButtons )
		{
			RecognizeVC.btnAnnounce.fadeTo( 0.6, 0.0 )
			RecognizeVC.btnSatisfaction.fadeTo( 0.6, 0.0 )
		}
		else
		{
			if ( FeatureVC.shared.IsShow ) { RecognizeVC.btnAnnounce.fadeTo( 0.5, 0.1 ); RecognizeVC.btnSatisfaction.fadeTo( 0.5, 0.1 ) } else { RecognizeVC.btnAnnounce.fadeTo( 0.6, 1.0 ); RecognizeVC.btnSatisfaction.fadeTo( 0.6, 1.0 ) }
		}

		if ( RtVars.IsEnableFeatureAdmin ) { RecognizeVC.btnFeatureAdmin.fadeTo( 0.5, 1.0 ) } else { RecognizeVC.btnFeatureAdmin.fadeTo( 0.5, 0.0 ) }
	}

	//==========================================================================================
	// handlers
	//==========================================================================================
	@objc func OnClickedAnnounce()
	{
		if ( FeatureVC.shared.IsShow ) { return }
		if ( RtVars.PauseReason.length > 0 ) { Log.Warn( "[App] cannot open announce in PauseMode" ); return }
		ShowPopupNewBy( .announce )
	}

	@objc func OnClickedSatisfaction()
	{
		if ( FeatureVC.shared.IsShow ) { return }
		if ( RtVars.PauseReason.length > 0 ) { Log.Warn( "[App] cannot open satisfaction in PauseMode" ); return }
		ShowPopupNewBy( .satisfaction )
	}

	@objc func OnClickedIntoCaptureMode()
	{
		FeatureVC.shared.toggleShow()
	}

	@objc func OnHoldForResetCapturer( _ uipgr: UILongPressGestureRecognizer )
	{
		if ( uipgr.state != .began ) { return }

		Log.Debug( "[App] Start Reset CameraCapturer" )
		CameraCapturer.shared.Restart()
		Log.Debug( "[App] Already Restart CameraCapturer via LongPress TimeBox" )
	}

	@objc func OnHoldForChangeDebugState( _ uipgr: UILongPressGestureRecognizer )
	{
		if ( uipgr.state != .began ) { return }

		let vwDepImg = CameraCapturer.shared.vwDepthImg!
		let vwDbgTxt = CameraCapturer.shared.vwDebugTxt!
		Async.main
		{
			if ( vwDepImg.layer.opacity <= 0 ) { vwDepImg.fadeIn() }
			else { vwDepImg.fadeOut() }
			if ( vwDbgTxt.layer.opacity <= 0 ) { vwDbgTxt.fadeIn() }
			else { vwDbgTxt.fadeOut() }
		}
	}

	func InitializeViews()
	{
		self.viewBg = ViewUtils.createAppBgView( self.view )
		self.viewFace = ViewUtils.createFitScreenImageView( parentView: self.view )

		ViewUtils.createTopBarView( self.view )
		ViewUtils.createLeftBarView( self.view, UIScreen.main.bounds.height * 1.5 / 8 )
		ViewUtils.createLeftBarView( self.view, UIScreen.main.bounds.height * 4.25 / 8 )
		ViewUtils.createBottomBarView( self.view )

		self.view.addSubview( FeatureVC.shared.view )

#if targetEnvironment( simulator )
		Log.Debug( "[App] current at Simulator mode" )
		//ViewUtils.setTestBoxes()
#endif
	}

	//==========================================================================================
	func refreshViews()
	{
		Async.main
		{
			let olds = RecognizeVC.FDOlds
			let news = RecognizeVC.FDNews

			for view in self.viewFace.subviews { view.removeFromSuperview() }

			//834,1482  834,1112
			for oldInfo in olds
			{
				// 設定Box
				let vBox = ViewUtils.setBoxBy( self.viewFace, oldInfo )

				var newFrame: CGRect?

				if let uuidO = oldInfo.uuid
				{
					for newInfo in news
					{
						if let uuidN = newInfo.uuid
						{
							if uuidO == uuidN
							{
								newFrame = newInfo.frame
								ViewUtils.setNameBoxBy( self.viewFace, newInfo )
							}
						}
					}
				}

				if let frame = newFrame
				{
					DispatchQueue.main.async
					{
						UIViewPropertyAnimator.runningPropertyAnimator( withDuration: 0.1, delay: 0, animations: { vBox.frame = frame }, completion: nil )
					}
				}
			}

			for obj in RecognizeVC.NowImgViews
			{
				self.viewFace.addSubview( obj.value )
			}
		}

		//------------------------------------------------------------------------
		if ( RtVars.IsEnableDepthCheck )
		{
			self.processCheckDepthImage()
			{
				ratio in

				if ( ratio >= 1.0 )
				{
					Log.Warn( "[CheckDepth] previous DepthImage different ratio[\( ratio )] restart Camera..." )
					CameraCapturer.shared.Restart()
				}
			}
		}
	}

	//==========================================================================================
	static let CheckDepthQueue = DispatchQueue( label: "queueCheckCamera" )
	static var CheckDepthLast = Date()
	static var CheckDepthPrevImg: UIImage?

	static var CheckDepthNilCount = 0

	func processCheckDepthImage( _ onCheck: @escaping ( Float ) -> Void )
	{
		if ( RtVars.PauseReason.length > 0 )
		{
			Log.Warn( "[CheckDepth] ignore check because PauseReason[\( RtVars.PauseReason )]" )
			return
		}

		RecognizeVC.CheckDepthQueue.sync
		{
			let now = Date()

			let secsCheck = now.timeIntervalSince( RecognizeVC.CheckDepthLast )
			if ( Int( secsCheck ) <= ( RtVars.DepthCheckSeconds ) ) { return }
			RecognizeVC.CheckDepthLast = now

			guard let imgNow = CameraCapturer.shared.NowImageDepth else
			{
				Log.Warn( "[CheckDepth] now Depth is [\( String( describing: CameraCapturer.shared.NowImageDepth ) )]" )
				RecognizeVC.CheckDepthNilCount += 1

				if ( RecognizeVC.CheckDepthNilCount >= 2 )
				{
					RecognizeVC.CheckDepthNilCount = 0
					Log.Warn( "[CheckDepth] the Depth Image nil count over limit, restart Camera..." )

					CameraCapturer.shared.Restart()
				}

				return
			}

			guard let imgPrev = RecognizeVC.CheckDepthPrevImg else
			{
				RecognizeVC.CheckDepthPrevImg = imgNow.clone()
				return
			}

			let imgNowToCompare = imgNow.clone()
			RecognizeVC.CheckDepthPrevImg = imgNow.clone()

			do
			{
				let ratio = try imgPrev.ComparePixelMatchPercentageBy( imgNowToCompare )
				Log.Debug( "[CheckDepth] different ratio[\( ratio )]" )

				Async.main
				{
					if CameraCapturer.shared.vwDepthImg.layer.opacity > 0
					{
						CameraCapturer.shared.vwDepthTxt.text = String( format: "%.2f", ratio )
					}
				}

				if ( ratio >= 1.0 ) // prevent comp during restart
				{
					RecognizeVC.CheckDepthLast = Date().addingTimeInterval( 15 )
					RecognizeVC.CheckDepthPrevImg = nil
				}

				onCheck( ratio )
			}
			catch
			{
				Log.Error( "[CheckDepth] check failed, \( error.localizedDescription )" )
			}
		}
	}
}
