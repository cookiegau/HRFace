import UIKit
import CtbcCore

class PopupVC: UIViewController
{
	public static let shared: PopupVC = PopupVC()

	enum Mode
	{
		case maintain
		case announce
		case satisfaction
	}

	static let textColor = UIColor.init( red: 108, green: 108, blue: 108 )

	var mode = Mode.maintain
	var rateScore: Int = 5

	lazy var btnDesc: UILabel =
			{
				let label = UILabel.init( frame: CGRect.init( x: 0, y: viewH * 5.3 / 10, width: viewW, height: viewH / 10 ) )
				label.text = "請依本次操作給予評分："
				label.font = UIFont.boldSystemFont( ofSize: 36 )
				label.textColor = UIColor.darkGray
				label.textAlignment = .center
				return label
			}()

	lazy var LabelMaintain: UILabel =
			{
				let label = UILabel()
				label.text = "目前正在維護\n服務暫停使用"
				label.textColor = PopupVC.textColor
				label.textAlignment = .center
				label.font = UIFont.systemFont( ofSize: 30 )
				label.numberOfLines = 3
				label.sizeToFit()

				return label
			}()

	var maintainMessage: String?
	{
		get { return LabelMaintain.text }
		set { LabelMaintain.text = newValue }
	}

	lazy var viewBgImg: UIImageView =
			{
				let imageView = UIImageView( frame: CGRect( x: 0, y: viewH * 4 / 10, width: viewW, height: viewH * 6 / 10 ) )
				imageView.backgroundColor = UIColor.clear
				return imageView
			}()

	lazy var btnCancel: UIButton =
			{
				let button = UIButton.init( frame: CGRect.init( x: 150, y: viewH * 8.5 / 10, width: 200, height: viewH / 10 ) )
				button.backgroundColor = UIColor.clear
				button.addTarget( self, action: #selector( OnClickedCancel ), for: .touchUpInside )
				if let image = UIImage.init( named: "button_cancel" )
				{
					let ratio = image.size.height / image.size.width
					button.setImage( image, for: .normal )
					button.frame.size = CGSize( width: 200, height: 200 * ratio )
				}
				button.alpha = 1
				return button
			}()

	lazy var btnOK: UIButton =
			{
				let button = UIButton.init( frame: CGRect.init( x: viewW - 350, y: viewH * 8.5 / 10, width: 200, height: viewH / 10 ) )
				button.backgroundColor = UIColor.clear
				button.addTarget( self, action: #selector( OnClickedOk ), for: .touchUpInside )
				if let image = UIImage.init( named: "button_send" )
				{
					let ratio = image.size.height / image.size.width
					button.setImage( image, for: .normal )
					button.frame.size = CGSize( width: 200, height: 200 * ratio )
				}
				button.isEnabled = false
				button.alpha = 1
				return button
			}()

	lazy var viewWhiteLayer: UIView =
			{
				let view = UIView.init( frame: UIScreen.main.bounds )
				view.backgroundColor = UIColor.white
				view.alpha = 0.5
				return view
			}()

	lazy var viewBtnRating: UIView =
			{
				let view = UIView.init( frame: CGRect( x: 100, y: viewH * 6.5 / 10, width: UIScreen.main.bounds.width - 200, height: 60 ) )
				view.backgroundColor = UIColor.white
				return view
			}()

	var sv: UIScrollView =
			{
				let scrollView = UIScrollView()
				let scrollViewWidth = viewW - 300
				scrollView.frame = CGRect( x: 150, y: viewH * 6 / 10, width: scrollViewWidth, height: viewH * 2 / 10 )
				scrollView.contentSize.width = CGFloat( 1 ) * scrollViewWidth
				scrollView.contentSize.height = 0
				scrollView.bounces = false
				scrollView.isPagingEnabled = true
				scrollView.backgroundColor = UIColor.white
				return scrollView
			}()

	var pageCtl: UIPageControl =
			{
				let pageControl = UIPageControl()
				//16 124 96
				pageControl.backgroundColor = UIColor.init( red: 16, green: 124, blue: 96 )
				pageControl.frame = CGRect( x: 0, y: viewH * 7 / 10, width: viewW, height: 30 )
				pageControl.numberOfPages = 3
				pageControl.currentPage = 0
				pageControl.addTarget( self, action: #selector( pageChanged ), for: .valueChanged )
				return pageControl
			}()

	let vIconRepair: UIImageView =
			{
				let imageView = UIImageView.init( frame: CGRect( x: viewW / 4, y: ( viewH - viewW / 2 ) / 2, width: viewW / 2, height: viewW / 2 ) )
				imageView.image = UIImage.init( named: "bg.box.Repair" )
				return imageView
			}()

	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupView( mode )
	}

	func setupView( _ mode: Mode )
	{
		self.view.backgroundColor = .clear
		self.view.addSubview( viewWhiteLayer )

		switch mode
		{
			case .satisfaction:
				self.view.addSubview( viewBgImg )
				self.view.addSubview( btnDesc )
				self.view.addSubview( btnCancel )
				self.view.addSubview( btnOK )
				self.view.addSubview( viewBtnRating )
				if let image = UIImage.init( named: "bg.box.Satisfaction" )
				{
					let ratio = image.size.height / image.size.width
					viewBgImg.image = image
					viewBgImg.frame.size = CGSize( width: viewBgImg.frame.size.width, height: viewBgImg.frame.size.width * ratio )
					viewBgImg.frame.origin.y = viewH - viewBgImg.frame.size.height
				}
				setRatingButton()

			case .announce:
				makeRowsViaApi()
				sv.delegate = self
				self.view.addSubview( viewBgImg )
				self.view.addSubview( btnDesc )
				self.view.addSubview( btnCancel )
				self.view.addSubview( sv )
				self.view.addSubview( pageCtl )
				if let image = UIImage.init( named: "bg.box.Announce" )
				{
					let ratio = image.size.height / image.size.width
					viewBgImg.image = image
					viewBgImg.frame.size = CGSize( width: viewBgImg.frame.size.width, height: viewBgImg.frame.size.width * ratio )
					viewBgImg.frame.origin.y = viewH - viewBgImg.frame.size.height
				}
				btnDesc.text = "訊息公告"
				btnCancel.frame.origin.x = ( viewW - btnCancel.frame.width ) / 2
				btnCancel.setImage( UIImage.init( named: "button_close" ), for: .normal )
				pageCtl.frame = CGRect( x: sv.frame.origin.x, y: sv.frame.origin.y + sv.frame.height, width: sv.frame.width, height: 30 )

			case .maintain:
				self.view.addSubview( viewBgImg )
				self.view.addSubview( vIconRepair )
				let bgView = viewBgImg
				viewBgImg.frame = vIconRepair.frame

				//bgView.frame.origin.x = bgView.frame.origin.width * 1.3

				let label = LabelMaintain
				label.frame = CGRect( x: 0, y: bgView.frame.height * 0.4, width: bgView.frame.width, height: bgView.frame.height / 2 )
				label.frame.origin.x = ( bgView.frame.width - label.frame.width ) / 2
				vIconRepair.addSubview( label )
		}
	}

	private func setRatingButton()
	{
		createRadioButton()
	}

	@objc func ratingButtonClick( _ sender: UIButton )
	{
		createRadioButton( sender )
	}

	private func createRadioButton( _ sender: UIButton? = nil )
	{
		var tag: Int = 5
		if let sender = sender
		{
			tag = sender.tag
			btnOK.isEnabled = true
		}
		if tag > 0
		{
			btnOK.isEnabled = true
		}
		for view in viewBtnRating.subviews
		{
			view.removeFromSuperview()
		}
		let originX: CGFloat = 0
		let gap: CGFloat = 20
		let width: CGFloat = ( viewBtnRating.frame.width - 4 * gap ) / 5
		viewBtnRating.frame.size = CGSize( width: viewBtnRating.frame.width, height: width * 1.5 )

		for idx in 0 ..< 5
		{
			let button = UIButton( frame: CGRect( x: originX + width * CGFloat( idx ) + gap * CGFloat( idx ), y: 0, width: width, height: width ) )
			viewBtnRating.addSubview( button )
			button.tag = idx + 1
			button.setTitleColor( UIColor.darkGray, for: .normal )
			button.addTarget( self, action: #selector( ratingButtonClick(_:) ), for: .touchUpInside )
			let label = UILabel.init( frame: CGRect( x: originX + width * CGFloat( idx ) + gap * CGFloat( idx ), y: width, width: width, height: width / 2 ) )
			label.text = "\( button.tag )"
			label.textAlignment = .center
			label.font = UIFont.boldSystemFont( ofSize: 36 )
			label.textColor = PopupVC.textColor
			viewBtnRating.addSubview( label )
			let image = idx < tag ? #imageLiteral( resourceName: "ball.Red" ) : #imageLiteral( resourceName: "ball.White" )
			button.setImage( image, for: .normal )
			button.backgroundColor = .clear
		}
		rateScore = tag
	}

	private func makeRowsViaApi()
	{
		Api.GetAnnounce
		{
			messages in

			Async.main
			{
				let size = Int( ceil( Double(messages.count) / 3 ) )
				//print( "[Rows] size[\( size )]" )
				self.pageCtl.numberOfPages = size
				self.sv.contentSize.width = CGFloat( size ) * ( viewW - 300 )

				let count = messages.count / 3 + 1
				let dwhat = messages.count % 3

				for idx in 0 ..< count
				{
					let originX: CGFloat = CGFloat( idx ) * self.sv.frame.width
					var originY: CGFloat = 20
					var pointOringinY: CGFloat = 34
					let view = UIView( frame: CGRect( x: originX, y: 0, width: self.sv.frame.width, height: self.sv.frame.height ) )
					self.sv.addSubview( view )

					let strLength = idx == count - 1 ? dwhat : 3
					for j in 0 ..< strLength
					{
						let pidx = idx * 3 + j
						let string = messages[pidx]
						let vLabel = self.getMarqueeLabel( string )

						view.addSubview( vLabel )
						vLabel.frame.origin.x = 20
						vLabel.frame.origin.y = originY
						let lineView = UIImageView( frame: CGRect( x: 0, y: originY + vLabel.frame.height + 1, width: viewW - 300, height: 1 ) )
						lineView.backgroundColor = UIColor.clear
						lineView.image = UIImage.init( named: "line" )
						lineView.contentMode = .scaleToFill
						lineView.frame.origin.x = idx == 0 ? 0 : originX
						let pointView = UIImageView( frame: CGRect( x: originX, y: pointOringinY, width: 10, height: 10 ) )
						pointView.image = UIImage.init( named: "ball.Green" )
						self.sv.addSubview( pointView )
						self.sv.addSubview( lineView )
						originY = originY + vLabel.frame.height + 20
						pointOringinY = pointOringinY + vLabel.frame.height + 20
					}
				}
			}
		}
	}

	func getMarqueeLabel( _ string: String ) -> UIView
	{
		let scrollView = UIScrollView( frame: CGRect( x: 0, y: 0, width: viewW - 340, height: 44 ) )
		let label = UILabel( frame: CGRect( x: 0, y: 0, width: viewW - 340, height: 44 ) )
		label.text = string
		label.textColor = PopupVC.textColor
		label.font = UIFont.boldSystemFont( ofSize: 30 )
		label.sizeToFit()
		scrollView.addSubview( label )
		if label.frame.width > scrollView.frame.width
		{
			let _ = Timer.scheduledTimer( withTimeInterval: 0.1, repeats: true )
			{
				( timer ) in
				let originX: CGFloat = label.frame.origin.x + label.frame.width > 0 ? label.frame.origin.x - 10 : 0
				let frame = CGRect( x: originX, y: label.frame.origin.y, width: label.frame.width, height: label.frame.height )
				UIViewPropertyAnimator.runningPropertyAnimator( withDuration: 0.1, delay: 0, animations: { label.frame = frame }, completion: nil )
			}
		}
		return scrollView
	}

	@objc func OnClickedOk()
	{
		if rateScore == 0
		{
			let pop = UIAlertController()
			pop.addAction( .init( title: "尚未評分", style: .default, handler: nil ) )
			RecognizeVC.shared.present( pop, animated: true, completion: nil )
		}
		else
		{
			Api.SendSatisfactionBy( rateScore )
			self.dismiss( animated: true, completion: nil )
		}
	}

	@objc func OnClickedCancel()
	{
		self.dismiss( animated: true, completion: nil )
	}
}

extension PopupVC: UIScrollViewDelegate
{
	// 當換頁時，ScrollView 必須捲動到適當位置，透過 setContentOffset 調整 ScrollView 的捲軸位置
	@objc func pageChanged()
	{
		let offset = CGPoint( x: ( sv.frame.width ) * CGFloat( pageCtl.currentPage ), y: 0 )
		sv.setContentOffset( offset, animated: true )
	}

	// 當 ScrollView 減速靜止時會被呼叫
	// 利用 ScrollView 的 offset 算出應該顯示哪一頁，讓 PageControl 顯示正確的頁數
	// 最後再調整 ScrollView 讓圖片置中
	func scrollViewDidEndDecelerating( _ scrollView: UIScrollView )
	{
		let page = Int( round( scrollView.contentOffset.x / scrollView.frame.width ) )
		pageCtl.currentPage = page
		let offset = CGPoint( x: CGFloat( page ) * scrollView.frame.width, y: 0 )
		scrollView.setContentOffset( offset, animated: true )
	}
}
