import Foundation
import UIKit
import AVFoundation
import CtbcCore

#if !arch( x86_64 )
import FaceCore
#endif

class ViewUtils
{
	//================================================================================================
	// utils
	//================================================================================================
	static func getImageWidthRatio( _ image: UIImage? ) -> CGFloat
	{
		var ratio: CGFloat = 1
		if let image = image { ratio = image.size.width / image.size.height }
		return ratio
	}

	static func getImageHeightRatio( _ image: UIImage? ) -> CGFloat
	{
		var ratio: CGFloat = 1
		if let image = image { ratio = image.size.height / image.size.width }
		return ratio
	}


	//================================================================================================
	public static func makeNewAnimeBy( _ rect: CGRect ) -> UIImageView
	{
		var animeImgs = [ UIImage ]()
		for i in 0 ... 12 { animeImgs.append( UIImage( named: "border_\( i )" )! ) }

		let imageView = UIImageView( frame: rect )
		imageView.animationImages = animeImgs
		imageView.animationDuration = 0.6
		imageView.animationRepeatCount = 1
		imageView.startAnimating()
		return imageView;
	}

	//================================================================================================
	// View Creators
	//================================================================================================
	public static func createFitScreenImageView( _ isTransparent: Bool = true, parentView: UIView? = nil ) -> UIImageView
	{
		let view = UIImageView( frame: CGRect( x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height ) )

		if ( isTransparent ) { view.backgroundColor = UIColor.clear }

		// if have parent
		if let parent = parentView { parent.addSubview( view ) }

		return view
	}

	public static func createAppBgView( _ parentView: UIView ) -> UIImageView
	{
		let view = UIView( frame: CGRect( x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height ) )
		view.backgroundColor = UIColor.clear
		let imgView = UIImageView( image: UIImage( named: "bg.App" ) )
		imgView.frame = CGRect( x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height )
		view.addSubview( imgView )

		parentView.addSubview( view )

		return imgView
	}

	static func createBtnHoldSecondsBy( _ seconds: Double, _ target: Any, _ selector: Selector, _ rect: CGRect ) -> UIButton
	{
		let btn = UIButton( frame: rect )
		//btn.layer.borderWidth = 2
		//btn.layer.borderColor = UIColor.red.cgColor

		let uipgr = UILongPressGestureRecognizer( target: target, action: selector )
		uipgr.minimumPressDuration = seconds
		btn.addGestureRecognizer( uipgr )

		return btn
	}

	public static func createTopBarView( _ parentView: UIView )
	{
		let vW: CGFloat = UIScreen.main.bounds.width
		//let vH: CGFloat = UIScreen.main.bounds.height / 8

		let view = UIView( frame: CGRect( x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 9 ) )
		view.backgroundColor = UIColor.clear

		let logoImageView = UIImageView( image: UIImage( named: "bar.Top" ) )
		logoImageView.frame = CGRect( x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * getImageHeightRatio( logoImageView.image ) )
		view.addSubview( logoImageView )


		// hidden buttons
		let btnResetCapturer = createBtnHoldSecondsBy( 3, RecognizeVC.shared, #selector( RecognizeVC.shared.OnHoldForResetCapturer ), CGRect( x: 30, y: 60, width: 200, height: 70 ) )
		view.addSubview( btnResetCapturer )
		let btnSwitchImgDepth = createBtnHoldSecondsBy( 2, RecognizeVC.shared, #selector( RecognizeVC.shared.OnHoldForChangeDebugState ), CGRect( x: 260, y: 60, width: 200, height: 70 ) )
		view.addSubview( btnSwitchImgDepth )


		let imgMenu = UIImage( named: "button_menu" )
		let btnMenu = UIButton( frame: CGRect( x: vW-74, y: 56, width: 38, height: 38 ) )
		btnMenu.setImage( imgMenu, for: .normal )
		btnMenu.actionHandler( controlEvents: .touchUpInside, ForAction: RecognizeVC.shared.OnClickedIntoCaptureMode )
		view.addSubview( btnMenu )

		RecognizeVC.btnFeatureAdmin = btnMenu

		parentView.addSubview( view )
	}

	public static func createLeftBarView( _ parentView: UIView, _ originY: CGFloat )
	{
		let viewHeight: CGFloat = UIScreen.main.bounds.height * 2 / 8
		var images = [ UIImage ]()
		for i in 0 ... 753
		{
			images.append( UIImage( named: "left bar_\( i )" )! )
		}
		let imageView = UIImageView( frame: CGRect( x: 30, y: originY, width: viewHeight * getImageWidthRatio( images.last ), height: viewHeight ) )
		imageView.backgroundColor = UIColor.clear
		imageView.animationImages = images
		imageView.startAnimating()

		parentView.addSubview( imageView )
	}

	static func createBtnTextBy( _ text: String, _ rect: CGRect ) -> UIButton
	{
		let btn = UIButton( frame: rect )
		btn.layer.backgroundColor = UIColor.white.cgColor
		btn.layer.borderWidth = 2.0
		btn.layer.borderColor = UIColor.black.cgColor
		btn.setTitle( text, for: .normal )
		btn.setTitleColor( UIColor.black, for: .normal )
		return btn
	}

	public static func createBottomBarView( _ parentView: UIView )
	{
		let vW: CGFloat = UIScreen.main.bounds.width
		let vH: CGFloat = UIScreen.main.bounds.height / 8

		let view = UIView( frame: CGRect( x: 0, y: UIScreen.main.bounds.height * 8 / 9 - 44, width: vW, height: vH ) )
		view.backgroundColor = UIColor.clear

		var currentX: CGFloat = 10
		let ivTimeBox = UIImageView( image: UIImage( named: "box.Time" ) )
		ivTimeBox.frame = CGRect( x: currentX, y: 0, width: UIScreen.main.bounds.height / 8 * getImageWidthRatio( ivTimeBox.image ), height: vH )
		view.addSubview( ivTimeBox )

		let formatter = DateFormatter()
		formatter.locale = Locale( identifier: "zh_Hant_TW" )

		let lbDate = UILabel( frame: CGRect( x: 28, y: 30, width: 250, height: 40 ) )
		lbDate.textColor = UIColor.white
		lbDate.font = UIFont.boldSystemFont( ofSize: 24 )
		let lbTime = UILabel( frame: CGRect( x: 28, y: 70, width: 270, height: 60 ) )
		lbTime.textColor = UIColor.white
		lbTime.font = UIFont.boldSystemFont( ofSize: 48 )
		lbTime.adjustsFontForContentSizeCategory = true
		ivTimeBox.addSubview( lbDate )
		ivTimeBox.addSubview( lbTime )
		let _ = Timer.scheduledTimer( withTimeInterval: 1, repeats: true )
		{
			( timer ) in

			let now = Date()
			formatter.dateFormat = "M月d日 EEEE"
			lbDate.text = formatter.string( from: now )
			formatter.dateFormat = "HH : mm : ss "
			lbTime.text = formatter.string( from: now )
			lbTime.textAlignment = .justified
		}

		//------------------------------------------------------------------------
		currentX = currentX + ivTimeBox.frame.width + 15

		let announceImage = UIImage( named: "button_announce" )
		let btnAnnounce = UIButton( frame: CGRect( x: currentX, y: ( vH - 88 ) / 2, width: 88 * getImageWidthRatio( announceImage ), height: 88 ) )
		btnAnnounce.setImage( announceImage, for: .normal )
		btnAnnounce.actionHandler( controlEvents: .touchUpInside, ForAction: RecognizeVC.shared.OnClickedAnnounce )
		view.addSubview( btnAnnounce )

//		let btnTest = createBtnTextBy( "Reset Capture", CGRect( x: currentX, y: ( vH + 80 ) / 2, width: 88 * getImageWidthRatio( announceImage ), height: 20 ) )
//		btnTest.actionHandler( controlEvents: .touchDown ) { }
//		view.addSubview( btnTest )

		//------------------------------------------------------------------------
		currentX = currentX + btnAnnounce.frame.width + 15

		let imgSatisfaction = UIImage( named: "button_survey" )
		let btnSatisfaction = UIButton( frame: CGRect( x: currentX, y: ( vH - 88 ) / 2, width: 88 * getImageWidthRatio( imgSatisfaction ), height: 88 ) )
		btnSatisfaction.setImage( imgSatisfaction, for: .normal )
		btnSatisfaction.actionHandler( controlEvents: .touchUpInside, ForAction: RecognizeVC.shared.OnClickedSatisfaction )
		view.addSubview( btnSatisfaction )


		parentView.addSubview( view )
		RecognizeVC.btnAnnounce = btnAnnounce
		RecognizeVC.btnSatisfaction = btnSatisfaction


		if let txtVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		{
			let lbVer = UILabel( frame: CGRect( x: vW-160, y: -(vH*6.1), width: 150, height: 30 ) )
			lbVer.textColor = UIColor.white
			lbVer.font = UIFont.boldSystemFont( ofSize: 16 )
			lbVer.adjustsFontForContentSizeCategory = true
			lbVer.text = txtVer
			lbVer.textAlignment = .right
			lbVer.alpha = 0.6

			view.addSubview( lbVer )
		}

		// auto update http response ms
		let lbMs = BaseLabel( frame: CGRect( x: vW-160, y: -(vH*6.7), width: 150, height: 30 ) )
		lbMs.textColor = UIColor.white
		lbMs.font = UIFont.boldSystemFont( ofSize: 9 )
		lbMs.adjustsFontForContentSizeCategory = true
		lbMs.text = "0 ms"
		lbMs.textAlignment = .right
		lbMs.alpha = 0.6

		view.addSubview( lbMs )

		_ = Timer.scheduledTimer( withTimeInterval: 0.1, repeats: true )
		{
			_ in
			Async.main{ lbMs.text = "\( Http.shared.timeLastDuration?.milliseconds ?? 0 ) ms" }
		}

	}

	//================================================================================================
	// Identify Box
	//================================================================================================
	static let Box_Green = "border_green"
	static let Box_Yellow = "border_yellow"
	static let Box_Red = "border_red"

	static let NBox_Green = "info box"
	static let NBox_Yellow = "info box_yellow"
	static let NBox_Red = "info box_red"

	static func setBoxBy( _ parentView: UIImageView, _ info: FaceDetail ) -> UIImageView
	{
		let imageView = UIImageView( frame: info.frame )

		var resName = Box_Red

		if info.id != nil
		{
			if ( RtVars.CurrentLivingMode )
			{
				resName = ( info.isLiving && info.isPunched ? Box_Green : Box_Yellow )
			}
			else
			{
				resName = ( info.isPunched ? Box_Green : Box_Yellow )
			}
		}

		let image = #imageLiteral( resourceName: resName )
		imageView.image = image

		parentView.addSubview( imageView )

		return imageView
	}

	static func setNameBoxBy( _ parentView: UIImageView, _ info: FaceDetail )
	{
		let width: CGFloat = 220
		let height: CGFloat = width * 0.6
		let frameFD = info.frame

		let wIcon: CGFloat = 38

		let view = UIImageView( frame: frameFD )
		view.frame.origin = CGPoint( x: frameFD.origin.x, y: frameFD.origin.y + frameFD.height + 20 )
		view.contentMode = .scaleToFill

		var resName = NBox_Red
		if info.id != nil
		{
			if ( RtVars.CurrentLivingMode )
			{
				resName = ( info.isLiving && info.isPunched ? NBox_Green : NBox_Yellow )
			}
			else
			{
				resName = ( info.isPunched ? NBox_Green : NBox_Yellow )
			}
		}


		view.image = #imageLiteral( resourceName: resName )
		view.frame.size = CGSize( width: width, height: height )
		//view.layer.borderWidth = 1; view.layer.borderColor = UIColor.red.cgColor

		let lbId = UILabel( frame: CGRect( x: 6, y: 0, width: view.frame.width - 10, height: view.frame.height / 3 ) )
		lbId.font = UIFont.systemFont( ofSize: 24 )
		lbId.textColor = UIColor( red: 23, green: 102, blue: 80 )
		if let id = info.id { lbId.text = "員編：\( id )" }

		let lbName = UILabel( frame: CGRect( x: 0, y: 0, width: view.frame.width - wIcon, height: view.frame.height * 2 / 3 ) )
		lbName.font = UIFont.systemFont( ofSize: 38 )
		lbName.textColor = UIColor.white
		lbName.textAlignment = .center
		//lbName.layer.borderColor = UIColor.blue.cgColor; lbName.layer.borderWidth = 2.0

		if let name = info.name, info.id != nil
		{
			lbName.text = name
			let orgF = lbName.frame
			lbName.sizeToFit()

			if ( lbName.frame.width < lbId.frame.width )
			{
				let newW = lbId.frame.width - ( wIcon + 12 )
				lbName.frame = CGRect( x: lbName.frame.origin.x, y: lbName.frame.origin.y, width: newW, height: lbName.frame.height )
			}

			let diffW = lbName.frame.width - orgF.width + 20
			lbName.frame = CGRect( origin: CGPoint( x: 10, y: view.frame.height / 2 ), size: lbName.frame.size )
			view.frame.size = CGSize( width: view.frame.width + diffW, height: view.frame.height )

			var imgBg: UIImage? = nil
			var imgTail: UIImage? = nil
			let imgIcon: UIImage? = nil
			if info.isPunched
			{
				imgBg = UIImage( named: "info-box_green_01" )
				imgTail = UIImage( named: "info-box_green_02" )
				//imgIcon = UIImage( named: "checked" )
			}
			else
			{
				imgBg = UIImage( named: "info-box_yellow_01" )
				imgTail = UIImage( named: "info-box_yellow_02" )
				//faceImage = UIImage( named: "face" )

				//lbName.text = "請微笑"
                lbName.font = UIFont.systemFont( ofSize: 36 )
                lbName.text = "請微笑或點我"


				if ( RtVars.CurrentLivingMode && info.isLiving )
				{
					let btn = BaseButton( frame: CGRect( x: 0, y: 0, width: view.frame.width, height: view.frame.height ) )
					btn.OnClick =
					{
						if let uuid = info.uuid, let id = info.id
						{
							Api.SendPunchBy( id, uuid )
							{
								RtVars.LastPunch = Date()
								RtVars.LastPunchId = id
								info.info.is_clock_in = true
							}
						}
					}
					view.isUserInteractionEnabled = true
					view.addSubview( btn )
					view.bringSubviewToFront( btn )

					parentView.isUserInteractionEnabled = true
				}
			}

			view.image = imgBg
			if let imgTail = imgTail
			{
				let ratio = imgTail.size.width / imgTail.size.height
				let ivTail = UIImageView( image: imgTail )
				let tailX = view.frame.width //- (imgTail.size.width/2)
				ivTail.frame = CGRect( x: tailX, y: 0, width: view.frame.height * ratio, height: view.frame.height )
				//ivTail.layer.borderWidth = 1; ivTail.layer.borderColor = UIColor.red.cgColor
				view.addSubview( ivTail )
			}

			if let imgFace = imgIcon
			{
				let ivFace = UIImageView( image: imgFace )
				ivFace.frame = CGRect( x: view.frame.width - 40, y: ( view.frame.height * 1 / 2 ) + 3, width: wIcon, height: wIcon )
				//ivFace.layer.borderWidth = 1; ivFace.layer.borderColor = UIColor.red.cgColor
				view.addSubview( ivFace )
			}
			else
			{
				let newW = view.frame.width
				lbName.frame = CGRect( x: lbName.frame.origin.x, y: lbName.frame.origin.y, width: newW, height: lbName.frame.height )
			}
		}
		view.addSubview( lbId )
		view.addSubview( lbName )

		parentView.addSubview( view )
	}

	static func setTestBoxes()
	{
		_ = Timer.scheduledTimer( withTimeInterval: 1.0, repeats: false )
		{
			_ in

			let fi = FaceInfo()
			fi.uuid = "Fake-UUID-1"
			fi.id = "Z12345678"
			fi.name = "測試人"
			RecognizeVC.FDNews.append( FaceDetail( fi, CGRect( x: 100, y: 300, width: 0, height: 0 ) ) )

			let fi1 = FaceInfo()
			fi1.uuid = "Fake-UUID-1-1"
			fi1.id = ""
			fi1.name = ""
			RecognizeVC.FDNews.append( FaceDetail( fi1, CGRect( x: 100, y: 450, width: 0, height: 0 ) ) )

			let fi2 = FaceInfo()
			fi2.uuid = "Fake-UUID-2"
			fi2.id = "Z12345678"
			fi2.name = "測試人已微笑"
			fi2.is_happy_detect = true
			RecognizeVC.FDNews.append( FaceDetail( fi2, CGRect( x: 380, y: 300, width: 0, height: 0 ) ) )

			let fi3 = FaceInfo()
			fi3.uuid = "Fake-UUID-2"
			fi3.id = "Z12345678"
			fi3.name = "Testing For English"
			fi3.is_happy_detect = true
			fi3.is_clock_in = true
			RecognizeVC.FDNews.append( FaceDetail( fi3, CGRect( x: 380, y: 450, width: 0, height: 0 ) ) )

			if RecognizeVC.FDOlds.count == 0 { RecognizeVC.FDOlds = RecognizeVC.FDNews }
			RecognizeVC.shared.refreshViews()
		}
	}
}
