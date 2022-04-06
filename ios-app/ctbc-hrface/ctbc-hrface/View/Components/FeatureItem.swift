import SwiftUI
import UIKit
import CtbcCore

public enum FeatureItemState
{
	case none
	case uploading
	case error
	case success
}

class User
{
	public var staffId: String?
	public var uuid: String?
	public var feature: [Double] = []
	public var Image: UIImage!

	public var state: FeatureItemState = .none
}

extension User: CustomStringConvertible
{
	public var description: String
	{
		var json = Json()
		json["uuid"].string = self.uuid
		json["staffId"].string = self.staffId

		return json.rawString( .utf8, options: [ .sortedKeys ] ) ?? "{}"
	}
}

class FeatureItem: UITableViewCell
{
	@IBOutlet weak var Picture: BaseImage!
	@IBOutlet weak var lbStaffId: BaseLabel!
	@IBOutlet weak var btnDel: BaseButton!

	var User: User!

	func RefreshStatus()
	{
		switch ( self.User.state )
		{
			case .none:
				self.btnDel.setTitle( "刪除", for: .normal )
				self.btnDel.backgroundColor = .systemRed
				self.animateBy( 0.5 ) { self.layer.opacity = 1.0 }
			case .uploading:
				self.btnDel.setTitle( "處理中", for: .normal )
				self.btnDel.backgroundColor = .systemBlue
				self.animateBy( 0.5 ) { self.layer.opacity = 1.0 }
			case .error:
				self.btnDel.setTitle( "失敗", for: .normal )
				self.btnDel.backgroundColor = .systemRed
			case .success:
				self.btnDel.setTitle( "上傳成功", for: .normal )
				self.btnDel.backgroundColor = .systemGreen
				self.animateBy( 0.5 ) { self.layer.opacity = 0.5 }
		}
	}
}
