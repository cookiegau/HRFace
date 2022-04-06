import UIKit
import CtbcCore

typealias OnToggle = ( _ isShow: Bool ) -> Void

class FeatureVC: UIViewController
{
	static let colorTxt = UIColor( red: 108, green: 108, blue: 108 )
	static let colorBG = UIColor.init( red: 35, green: 102, blue: 84 )

	public static let shared: FeatureVC = FeatureVC()

	public let Users: ThreadSafeArray<User> = ThreadSafeArray()
	public var AdminStaffId: String? = nil

	public var IsShow: Bool { get { return self.view.layer.opacity > 0 } }

	var lbTitle: UILabel =
	{
		let label = UILabel()
		label.text = "Initialize..."
		label.textColor = .white
		label.textAlignment = .center
		label.font = UIFont.systemFont( ofSize: 33 )
		label.numberOfLines = 2

		label.frame = CGRect( x: 80, y: 160, width: 500, height: 100 )
		label.layer.opacity = 0
		label.layer.shadowRadius = 3
		label.layer.shadowOpacity = 1
		label.layer.shadowOffset = .zero

		return label
	}()

	var btnAdd: BaseButton =
	{
		let btn = BaseButton( title: "加入" )
		btn.frame = CGRect( x: 80 + 50, y: 920, width: 400, height: 70 )
		btn.setBorderBy( .white, 1 )
		btn.setShadowBy( UIColor( hex: 0xCCCCCC ), 0.3 )
		btn.titleLabel!.font = UIFont.systemFont( ofSize: 30 )

		btn.layer.cornerRadius = 10
		btn.layer.backgroundColor = FeatureVC.colorBG.cgColor

		return btn
	}()

	var btnUpload: BaseButton =
	{
		let btn = BaseButton( title: "上傳" )
		btn.frame = CGRect( x: viewW - 180, y: 920, width: 160, height: 60 )
		btn.setBorderBy( .white, 1 )
		btn.setShadowBy( UIColor( hex: 0xCCCCCC ), 0.3 )
		btn.titleLabel!.font = UIFont.systemFont( ofSize: 30 )

		btn.layer.cornerRadius = 10
		btn.layer.backgroundColor = FeatureVC.colorBG.cgColor
		btn.layer.opacity = 0.5

		return btn
	}()

	var vwBg: UIImageView =
	{
		let view = UIImageView( frame: CGRect( x: viewW - 200, y: 0, width: 200, height: viewH ) )
		view.image = UIImage( named: "bg.ModeCapture" )
		view.backgroundColor = .clear
		return view
	}()

	var vwBox: UIView =
	{
		let vw = UIView( frame: CGRect( x: viewW, y: 165, width: 250, height: 750 ) )
		vw.backgroundColor = UIColor.white.withAlphaComponent( 0.8 )
		vw.layer.cornerRadius = 10
		vw.layer.shadowColor = UIColor.black.cgColor
		vw.layer.shadowOpacity = 0.5

		vw.setBorderBy( colorBG, 5 )

		return vw
	}()

	var vwTable: BaseTable =
	{
		let tv = BaseTable( CGRect( x: 5, y: 5, width: 215, height: 740 ) )
		tv.backgroundColor = UIColor.white.withAlphaComponent( 0.0 )
		tv.separatorColor = .clear
		tv.RegisterBy( nibName: "FeatureItem" )


		tv.isScrollEnabled = true
		tv.estimatedRowHeight = 99
		tv.numberOfRowsInSection = { idx in return 1 }
		tv.numberOfSectionsInTableView = { ( tv ) in return FeatureVC.shared.Users.count }

		tv.cellForRowAtIndexPath =
		{
			( tb, idxP ) -> UITableViewCell in


			let user = FeatureVC.shared.Users[idxP.section]
			let cell = tb.dequeueReusableCell( withIdentifier: "FeatureItem", for: idxP ) as! FeatureItem
			cell.User = user
			cell.RefreshStatus()
			cell.lbStaffId.text = user.staffId ?? "點擊輸入員編"
			cell.Picture.image = user.Image

			if ( user.state == .success )
			{
				cell.contentView.layer.opacity = 0.6
			}
			else
			{
				cell.contentView.layer.opacity = 1.0
			}

			let onClicked =
			{
				FeatureVC.shared.view.ShowAlertToGetTextBy( "填寫員編", "請輸入8碼員編" )
				{
					gotTxt in
					if let txt = gotTxt
					{
						guard let sid = Int( txt ) else
						{
							FeatureVC.shared.view.ShowAlertBy( "填寫員編", "格式為8碼數字, 請重新輸入" )
							return
						}
						guard sid <= 99999999 && sid >= 1 else
						{
							FeatureVC.shared.view.ShowAlertBy( "填寫員編", "格式為8碼數字, 請重新輸入" )
							return
						}

						var sidStr = "\( sid )"
						while ( sidStr.length < 8 ) { sidStr = "0" + sidStr }

						user.staffId = "\( sidStr )"
						FeatureVC.shared.vwTable.reloadData()
					}
				}
			}

			cell.lbStaffId.OnClick = onClicked
			cell.Picture.OnClick = onClicked

			cell.btnDel.OnClick =
			{
				FeatureVC.shared.view.ShowAlertYesNoBy( "刪除確認", "請確認是否刪除" )
				{
					cell.animateBy( 0.5 )
					{
						FeatureVC.shared.Users.removeAtIndex( idxP.section )
						FeatureVC.shared.vwTable.reloadData()
					}
				}
			}

			return cell
		}


		return tv
	}()

	var sv: UIScrollView =
	{
		let svW = viewW - 300
		let svH = viewH - 300
		let sv = UIScrollView( frame: CGRect( x: 150, y: viewH * 6 / 10, width: svW, height: viewH ) )
		sv.contentSize.width = CGFloat( 1 ) * svW
		sv.contentSize.height = 0
		sv.bounces = false
		return sv
	}()

	let btnClose: BaseButton =
	{
		let btn = BaseButton( imageName: "btn.Menu.Close" )
		btn.frame = CGRect( x: viewW - 74, y: 56, width: 38, height: 38 )
		return btn
	}()

	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupView()
	}

	func toggleShow( _ forceHide: Bool = false )
	{
		if forceHide || self.IsShow
		{
			let action = {
				FeatureVC.shared.Users.removeAll()
				self.view.fadeOut( 0.5 )
				self.view.animateBy( 1.0 )
				{
					self.vwBox.transform = CGAffineTransform( translationX: +220, y: 0 )
				}
				RecognizeVC.OnButtonStateChanged()
			}

			if ( FeatureVC.shared.Users.count <= 0 )
			{
				action()
			}
			else
			{
				TryValidCurrentAdminBy( false )
				{
					self.view.ShowAlertYesNoBy( "系統提示", "離開將會清空錄製資料\n您是否確定要離開錄製功能?" )
					{
						action()
					}
				}
			}
		}
		else if let fd = RecognizeVC.CurrentFaceDetail
		{
			Log.Debug( "[IPad:Feature] trying to Open FeatureRecord by StaffId[\( fd.id ?? "unknown" )]" )
			TryValidCurrentAdminBy
			{
				self.vwTable.reloadData()
				self.view.fadeIn( 0.5 )
				self.view.animateBy( 1.0 )
				{
					self.vwBox.transform = CGAffineTransform( translationX: -220, y: 0 )
				}
				RecognizeVC.OnButtonStateChanged()
			}
		}
		else
		{
			Log.Warn( "[IPad:Feature] trying to Open FeatureRecord but not available StaffId" )
		}
	}

	func TryValidCurrentAdminBy( _ needDoubleCheck: Bool = true, _ onDone: @escaping IAction )
	{
		guard let fd = RecognizeVC.CurrentFaceDetail else
		{
			Log.Debug( "[IPad:Feature] current not have only one people" );
			return
		}
		guard let adminStaffId = fd.id else
		{
			Log.Warn( "[IPad:Feature] current user not have staffId" );
			return
		}
		guard let nowStaffId = Int( adminStaffId ) else
		{
			Log.Warn( "[IPad:Feature] current user staffId[\( adminStaffId )] not valid" );
			return
		}

		let code = RtVars.AdminValidCode
		guard RtVars.AdminIds.contains( nowStaffId ) else
		{
			Log.Warn( "[IPad:Feature] current adminIds not contains staffId[\( nowStaffId )]" );
			return
		}

		if ( needDoubleCheck && RtVars.CurrentIsOffLivingDetectTime )
		{
			FeatureVC.shared.view.ShowAlertBy( "管理員功能", "目前為非活體時段, 無法執行管理員功能" );
			return
		}

		guard fd.isPunched else
		{
			FeatureVC.shared.view.ShowAlertBy( "管理員功能", "請先完成微笑打卡" );
			return
		}


		if ( ( !needDoubleCheck ) || ( code.length <= 0 ) )
		{
			self.AdminStaffId = adminStaffId
			Log.Debug( "[IPad:Feature] user login admin mode success, staffId[\( String( describing: self.AdminStaffId ) )]" )
			onDone()
			return
		}

		FeatureVC.shared.view.ShowAlertToGetTextBy( "密碼驗證", "請輸入管理員驗證碼" )
		{
			getTxt in

			guard let txt = getTxt else
			{
				FeatureVC.shared.view.ShowAlertBy( "密碼驗證", "密碼不得為空" );
				return
			}
			guard txt == code else
			{
				Log.Warn( "[IPad:Feature] user input code[\( txt )] not match" )
				FeatureVC.shared.view.ShowAlertBy( "密碼驗證", "密碼驗證失敗" );
				return
			}

			self.AdminStaffId = adminStaffId
			Log.Debug( "[IPad:Feature] user login admin mode success, staffId[\( String( describing: self.AdminStaffId ) )]" )
			onDone()
		}
	}

	func setupView()
	{
		self.view.frame = CGRect( x: 0, y: 0, width: viewW, height: viewH )
		self.view.backgroundColor = .clear

		self.view.addSubview( vwBg )
		self.view.addSubview( vwBox )
		vwBox.addSubview( vwTable )


		//title
		self.view.addSubview( lbTitle )
		self.view.addSubview( btnAdd )
		self.view.addSubview( btnClose )
		self.view.addSubview( btnUpload )


		btnAdd.OnClick = FeatureVC.shared.OnClickedAdd
		btnUpload.OnClick = FeatureVC.shared.OnClickedUpload
		btnClose.OnClick = { self.toggleShow( true ) }

		view.animateBy( 1.0 )
		{
			self.vwBox.transform = CGAffineTransform( translationX: -220, y: 0 )
		}
		view.animateBy( 3 )
		{
			self.lbTitle.layer.opacity = 1
		}

		self.StartTimer()
		self.view.layer.opacity = 0
	}

	var timer: Timer?

	func StartTimer()
	{
		if let tm = timer { tm.invalidate() }
		timer = Timer.scheduledTimer( withTimeInterval: 0.1, repeats: true, block: { timer in self.OnProcessScreenStats( timer: timer ) } )
	}

	func OnProcessScreenStats( timer: Timer )
	{
		if ( !timer.isValid || !self.IsShow ) { return }

		if ( RecognizeVC.FDNews.count <= 0 )
		{
			Async.main
			{
				self.lbTitle.text = "請站到畫面中間"

#if !targetEnvironment( simulator )
				if ( !FeatureVC.shared.btnAdd.IsRunning )
				{
					self.view.animateBy( 0.5 ) { self.btnAdd.layer.opacity = 0.5 }
				}
#endif
			}
		}
		else if ( RecognizeVC.FDNews.count >= 2 )
		{
			Async.main
			{
				self.lbTitle.text = "請保持畫面中僅有一個位成員"

				if ( !FeatureVC.shared.btnAdd.IsRunning )
				{
					self.view.animateBy( 0.5 ) { self.btnAdd.layer.opacity = 0.5 }
				}
			}
		}
		else
		{
			Async.main
			{
				self.lbTitle.text = "請點擊下方加入按鈕"

				if ( !FeatureVC.shared.btnAdd.IsRunning )
				{
					FeatureVC.shared.btnAdd.IsCanFire = true
					self.view.animateBy( 0.5 ) { self.btnAdd.layer.opacity = 1.0 }
				}
			}
		}

		let fd = RecognizeVC.CurrentFaceDetail

		let btnUpload = FeatureVC.shared.btnUpload
		if ( fd != nil && !btnUpload.IsRunning && FeatureVC.shared.Users.count >= 1 )
		{
			Async.main { btnUpload.layer.opacity = 1 }
		}
		else
		{
			Async.main { btnUpload.layer.opacity = 0.5 }
		}

		let btnAdd = FeatureVC.shared.btnAdd
		if ( RecognizeVC.FDNews.count == 1 && btnAdd.IsCanFire && !btnAdd.IsRunning )
		{
			Async.main { btnAdd.layer.opacity = 1 }
		}
		else
		{
			Async.main { btnAdd.layer.opacity = 0.5 }
		}
	}

	func OnClickedAdd()
	{
		let btn = FeatureVC.shared.btnAdd
		btn.IsRunning = true
		//------------------------------------------------------------------------

		let user = User()

		//------------------------------------------------------------------------
#if !targetEnvironment( simulator )
		if RecognizeVC.FDNews.count <= 0
		{
			Log.Error( "[Feature] not have available Face" )
			btn.IsRunning = false
			return
		}
		if RecognizeVC.FDNews.count >= 2
		{
			Log.Error( "[Feature] available Face more then one" )
			btn.IsRunning = false
			return
		}

		let fd = RecognizeVC.FDNews[0]
		if ( fd.feature.count != 512 )
		{
			Log.Error( "[Feature] cannot get feature from current FaceInfo: \( fd )" )
			btn.IsRunning = false
			return
		}
		else
		{
			if let staffId = fd.id { user.staffId = staffId }
			user.feature = fd.feature
			user.Image = fd.image
		}

		user.uuid = fd.uuid ?? ""
#endif

		FeatureVC.shared.Users.append( user )

		let tv = FeatureVC.shared.vwTable
		tv.reloadData()


		let indexPath = IndexPath( row: 0, section: FeatureVC.shared.Users.count - 1 )
		tv.cellForRow( at: indexPath )
		tv.scrollToRow( at: indexPath, at: .top, animated: true )

		btn.IsRunning = false
	}

	func OnClickedUpload()
	{
		TryValidCurrentAdminBy( false )
		{
			self.OnStartProcessUpload()
		}
	}

	func OnStartProcessUpload()
	{
		let users = self.Users
		if ( users.count <= 0 )
		{
			self.view.ShowAlertBy( "系統提示", "尚未錄製任何特徵值" )
			return
		}
		guard let adminStaffId = AdminStaffId else
		{
			self.view.ShowAlertBy( "系統提示", "錯誤的操作,\n沒有管理員Id" )
			return
		}

		let vt = self.vwTable
		let btnUpload = self.btnUpload
		let btnAdd = self.btnAdd

		btnUpload.IsRunning = true
		btnAdd.IsCanFire = false
		self.view.animateBy( 1 ) { btnUpload.layer.opacity = 0.5 }
		Log.Debug( "[Upload] start..." )

		//------------------------------------------------------------------------
		let all: [User] = users.clone()
		var oks: [User] = []
		var nos: [User] = []

		func scrollTableBy( _ idx: Int )
		{
			Async.main
			{
				vt.reloadData()
				if ( idx + 1 <= all.count )
				{
					let idxP = IndexPath( row: 0, section: idx )
					vt.scrollToRow( at: idxP, at: .top, animated: true )
				}
			}
		}

		//------------------------------------------------------------------------
		var idx = 0

		func refreshToNext()
		{
			idx = idx + 1
			scrollTableBy( idx )

			Log.Debug( "[refreshToNext] idx[\( idx )]" )

			if ( idx >= all.count )
			{
				Log.Debug( "[refreshToNext] finished idx[\( idx )]" )
				Async.main
				{
					Log.Debug( "[Upload] finished, idx[\( idx )] all[\( all.count )]" )
					self.view.ShowAlertBy( "上傳完成", "成功筆數[ \( oks.count ) ]\n失敗筆數[ \( nos.count ) ]" )
					{
						Async.main
						{
							btnAdd.IsCanFire = true
							btnUpload.IsRunning = false
						}
					}
				}
			}
			else
			{
				processUploadIdx()
			}
		}

		func processUploadIdx()
		{
			let user = all[idx]
			if ( user.state == .success )
			{
				refreshToNext()
				return
			}

			if let uuid = user.uuid, let staffId = user.staffId
			{
				guard let sid = Int( staffId ) else
				{
					Log.Debug( "[Upload] idx[\( idx )] not have staffId" )
					user.staffId = "必需輸入員編"
					user.state = .error
					nos.append( user )

					refreshToNext()
					return
				}
				guard sid <= 99999999 else
				{
					Log.Debug( "[Upload] idx[\( idx )] staffId[\( staffId )]" )
					user.staffId = "員編格式錯誤"
					user.state = .error
					nos.append( user )

					refreshToNext()
					return
				}

				let model = IPadFeature( uuid, staffId, user.feature, adminStaffId )
				Api.SendFeatureAddBy( model,
				{
					Log.Debug( "[Upload] idx[\( idx )] success staffId[\( model.staffId )]" )
					user.state = .success
					oks.append( user )

					refreshToNext()
				},
				{
					ex in
					Log.Error( "[Upload] idx[\( idx )] error on staffId[\( model.staffId )], code[\( ex.code )] \( ex.message ), \( ex.error )" )
					user.state = .error
					nos.append( user )

					if ( ex.code == 500 && ex.body.length > 0 )
					{
						self.view.ShowAlertBy( "上傳異常", "伺服器訊息[ \( ex.body ) ]" )
						{
							refreshToNext()
						}
					}
					else
					{
						refreshToNext()
					}
				} )
			}
			else
			{
				Log.Debug( "[Upload] idx[\( idx )] skip, data[\( user )]" )
				user.staffId = "必需輸入員編"
				user.state = .error
				nos.append( user )
				refreshToNext()
			}
		}

		//------------------------------------------------------------------------
		Async.utility
		{
			scrollTableBy( 0 )
			processUploadIdx()
		}
	}
}
