import Foundation
import CtbcCore
import UIKit

#if !arch( x86_64 )
import FaceCore
#endif

extension FaceInfo
{
	public var idStr: String?
	{
		if let value = self.id as String?, value.length >= 1 { return value }
		return nil
	}
	public var uuidStr: String?
	{
		if let value = self.uuid as String?, value.length >= 1 { return value }
		return nil
	}
	public var nameStr: String?
	{
		if let value = self.name as String?, value.length >= 1 { return value }
		return nil
	}

	public var dx1: Double? { return self.x1 as? Double }
	public var dx2: Double? { return self.x2 as? Double }
	public var dy1: Double? { return self.y1 as? Double }
	public var dy2: Double? { return self.y2 as? Double }
}

public class FaceDetail
{
	let info: FaceInfo
	let frame: CGRect

	let id: String?
	let uuid: String?
	let name: String?

	let isLiving: Bool
	let isPunched: Bool

	private(set) var image: UIImage!
	private(set) var feature: [Double] = []

	init( _ info: FaceInfo, _ frame: CGRect )
	{
		self.info = info

		self.frame = frame
		self.isLiving = info.is_living
		self.isPunched = info.is_clock_in

		if let img = info.croped { self.image = img }

		self.id = info.idStr
		self.uuid = info.uuidStr
		self.name = info.nameStr

		if let matrix = info.feature { self.feature = matrix }
	}
}
