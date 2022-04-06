#if arch( x86_64 )
//======================================================================================================
// mock framework for Simulator
//======================================================================================================
import AVFoundation
import CommonCrypto
import CoreData
import CoreML
import Foundation
import struct Foundation.Data
import MobileCoreServices
import Security
import UIKit
import zlib

//! Project version number for
public var FaceCoreVersionNumber: Double = 0.0



@objc public class DetectInfo: NSObject
{

	@objc public var face_list: [FaceInfo]?

	@objc public var origin_image: UIImage?
}

@objc public enum DrawFace: Int
{

	case no

	case rectangle

	case points

	case rectangle_points
}

@objc public class FaceClockInLog: NSObject
{

	public var clock_in: Bool?

	public var clock_in_time: Date?

	public var correct: Bool?

	public var face_img: Data?

	public var feature: [Double]?

	public var rec_face_img: Data?

	public var rec_create_time: Date?

	public var id: String?

	public var name: String?
}

@objc public class FaceInfo: NSObject
{

	@objc public var x1: NSNumber?

	@objc public var y1: NSNumber?

	@objc public var x2: NSNumber?

	@objc public var y2: NSNumber?

	@objc public var ppoint: [[Float]]?

	@objc public var area: NSNumber?

	@objc public var croped: UIImage?

	@objc public var depth: UIImage?

	@objc public var alignment: UIImage?

	@objc public var feature: [Double]?

	public var is_detect: Bool?

	public var is_happy_detect: Bool = false

	public var found_time: Date?

	public var create_time: Date?

	public var features: [FaceResource]?

	@objc public var name: NSString?

	@objc public var id: NSString?

	@objc public var uuid: NSString?

	@objc public var is_living: Bool = false

	@objc public var is_clock_in: Bool = false
}

@objc public class FaceRecLog: NSObject
{

	public var correct: Bool?

	public var face_img: Data?

	public var feature: [Double]?

	public var rec_face_img: Data?

	public var rec_create_time: Date?

	public var id: String?

	public var name: String?

	public var rec_time: Date?

	public var status: Int32 = 0
}

@objc public class FaceResource: NSObject
{

	public var create_time: Date?

	public var image: Data?

	public var resource: [Double]?

	public var feature_id: String?
}

@objc(Features) public class Features: NSManagedObject
{
}

extension Features
{

	@nonobjc public class func fetchRequest() -> NSFetchRequest<Features> { return NSFetchRequest<Features>() }

	@NSManaged public var create_time: Date?

	@NSManaged public var feature_id: String?

	@NSManaged public var image: Data?

	@NSManaged public var resource: [Double]?

	@NSManaged public var user: User?
}

@objc(User) public class User : NSManagedObject {
}



@objc public enum ModelType: Int
{

	case tiny

	case normal
}

@objc public enum Orientation: Int
{

	case normal

	case mirror
}

@objc(RecLog) public class RecLog: NSManagedObject
{
}

extension RecLog
{

	@nonobjc public class func fetchRequest() -> NSFetchRequest<RecLog> { return NSFetchRequest<RecLog>() }

	@NSManaged public var correct: Bool

	@NSManaged public var face_img: Data?

	@NSManaged public var feature: [Double]?

	@NSManaged public var id: String?

	@NSManaged public var name: String?

	@NSManaged public var rec_create_time: Date?

	@NSManaged public var rec_face_img: Data?

	@NSManaged public var rec_time: Date?

	@NSManaged public var status: Int32
}


/**
Handles providing singletons of NSURLSession.
*/
public class SharedSession
{

	public static let defaultSession: URLSession = URLSession()
}



extension UIImage {

    /**
     Resizes the image to width x height and converts it to an RGB CVPixelBuffer.
     */
    public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? { return nil }
}




@objc public protocol CTBCFaceDetectionDelegate: AnyObject
{
	@objc optional func recognized( _ info: FaceInfo )

	@objc optional func found( _ info: FaceInfo )

	@objc optional func timeout( _ info: FaceInfo )

	@objc optional func unknow( _ info: FaceInfo )

	@objc optional func happy( _ info: FaceInfo )

	@objc optional func living( _ info: FaceInfo )
}

public class CTBCFaceDetection: NSObject
{

	weak public var delegate: CTBCFaceDetectionDelegate!

	@objc public var detect_info: DetectInfo?

	@objc public var recognition_list: [FaceInfo]?

	@objc public let data_io: DataIO? = nil


	@objc public func setNameCount( threshold: Int ) {}

	@objc public func setMatchCount( threshold: Int ) {}

	@objc public func setHoldSecond( threshold: Int ) {}

	@objc public func setTrackingMatch( is_tracking: Bool, threshold: Double ) {}

	@objc public func setHappyThreshold( threshold: Double ) {}

	@objc public func setHappyCount( threshold: Int ) {}

	@objc public func setSmileDetect( is_activate: Bool ) {}

	@objc public func setLivingDetect( is_activate: Bool ) {}

	@objc public func setLivingThreshold( threshold: Double ) {}

	@objc public func setLivingCount( threshold: Int ) {}

	@objc public func setDeviceID( id: String ) {}

	@objc public func setModelType( model_type: ModelType ) {}

	@objc public func checkSmile( check: Bool ) {}

	@objc public func add( source_image: UIImage, name: String ) -> String { return "" }

	@objc public func create_user( source_image: UIImage, name: String ) -> FaceInfo { return FaceInfo() }

	@objc public func add( feature: [Double], name: String ) -> String { return "" }

	@objc public func detectImage( source_image: UIImage, draw_face: DrawFace = .no, orientation: Orientation = .mirror, min_size: Int = 30 ) -> FaceInfo { return FaceInfo() }

	@objc public func detectWithService( source_image: UIImage, draw_face: DrawFace = .rectangle_points, orientation: Orientation = .mirror, min_size: Int = 30, max_iou: Double = 0.5, min_iou: Double = 0.1 ) {}

	@objc public func detectWithServiceDepth( source_image: UIImage, depth_image: UIImage, draw_face: DrawFace = .rectangle_points, orientation: Orientation = .mirror, min_size: Int = 30, max_iou: Double = 0.5, min_iou: Double = 0.1 ) {}

	@objc public func setLogUrl( send_log: Bool, url: String ) {}

	public func addUserWithService( user: FaceInfo, feature: [Double], feature_id: String, complete: @escaping ( String, Bool ) -> () ) {}

	public func deleteUserWithService( user: FaceInfo, feature: [Double], feature_id: String, complete: @escaping ( String, Bool ) -> () ) {}

	public func setServiceUrl( url: String ) {}

	public func setLicenseUrl( url: String ) {}

	public func setAPITokenInfo( url: String, user_name: String, password: String ){}

	public func checkAPIToken(  complete: @escaping ( String, Bool) -> Void )
	{
		complete( "", true )
	}
	public func checkLicense( key: String, complete: @escaping ( String, Bool ) -> () )
	{
		complete( "", true )
	}
	
	public func setRequestTimeout( sec: Double ) {}
	public func setTempCount( threshold: Int ) {}
}


@objc(ClockInLog) public class ClockInLog: NSManagedObject
{
}

extension ClockInLog
{

	@nonobjc public class func fetchRequest() -> NSFetchRequest<ClockInLog> { return NSFetchRequest<ClockInLog>() }

	@NSManaged public var clock_in: Bool

	@NSManaged public var clock_in_time: Date?

	@NSManaged public var correct: Bool

	@NSManaged public var face_img: Data?

	@NSManaged public var feature: [Double]?

	@NSManaged public var id: String?

	@NSManaged public var name: String?

	@NSManaged public var rec_create_time: Date?

	@NSManaged public var rec_face_img: Data?
}

/// Compression level whose rawValue is based on the zlib's constants.
public struct CompressionLevel: RawRepresentable
{

	/// Compression level in the range of `0` (no compression) to `9` (maximum compression).
	public let rawValue: Int32 = 0

	public static let noCompression: CompressionLevel = .noCompression

	public static let bestSpeed: CompressionLevel = .bestSpeed

	public static let bestCompression: CompressionLevel = .bestCompression

	public static let defaultCompression: CompressionLevel = .defaultCompression

	/// Creates a new instance with the specified raw value.
	///
	/// If there is no value of the type that corresponds with the specified raw
	/// value, this initializer returns `nil`. For example:
	///
	///     enum PaperSize: String {
	///         case A4, A5, Letter, Legal
	///     }
	///
	///     print(PaperSize(rawValue: "Legal"))
	///     // Prints "Optional("PaperSize.Legal")"
	///
	///     print(PaperSize(rawValue: "Tabloid"))
	///     // Prints "nil"
	///
	/// - Parameter rawValue: The raw value to use for the new instance.
	public init( rawValue: Int32 ) {}

	public init( _ rawValue: Int32 ) {}
}

@objc public class DataIO: NSObject
{

	public static let shared: DataIO = DataIO()

	public func createUser( info: FaceInfo ) -> FaceInfo { return FaceInfo() }

	public func findAllUser() -> [FaceInfo] { return [ FaceInfo ].init() }

	public func findUser( id: String, name: String ) -> FaceInfo { return FaceInfo() }

	public func updateUser( image: UIImage, resource: [Double], info: FaceInfo ) {}

	public func addUserFeature( image: UIImage, resource: [Double], info: FaceInfo ) -> FaceInfo { return FaceInfo() }

	public func deleteAllUser() {}

	public func deleteUser( info: FaceInfo ) {}

	public func deleteUserFeature( resource: [Double], info: FaceInfo ) -> FaceInfo { return FaceInfo() }

	public func deleteUserFeature( resource: FaceResource, info: FaceInfo ) -> FaceInfo { return FaceInfo() }

	public func createClockInLog( info: FaceInfo, clock_in: Bool, correct: Bool ) {}

	public func createRecLog( info: FaceInfo ) {}

	public func findAllRecLog() -> [FaceRecLog] { return [ FaceRecLog ].init() }

	public func findRecLogByDate( startDate: Date, endDate: Date ) -> [FaceRecLog] { return [ FaceRecLog ].init() }

	public func findAllClockInLog() -> [FaceClockInLog] { return [ FaceClockInLog ].init() }

	public func findClockInLogByDate( startDate: Date, endDate: Date ) -> [FaceClockInLog] { return [ FaceClockInLog ].init() }
}



#endif
