import Foundation

public class RtVars
{
	public static let AppLaunch = Date()

	public static var IsUpdated = false

	public static var PauseReason = ""
	public static var IsAllowLocalLog = true
	public static var IsAllowServerLog = true
	public static var IsServerLogFullMode = true


	public static var MaintainMessage = ""
	public static var IsDisableButtons = false
	public static var IsEnableFeatureAdmin = false

	public static var IsEnableDepthCheck = true
	public static var DepthCheckSeconds = 15

	public static var OffLivingDetectTimes: [TimeRange] = []
	public static var CurrentIsOffLivingDetectTime = false

	public static var LastPunch: Date?
	public static var LastPunchId: String?
	public static var LastDetectInfo = Date()

	public static var AdminIds: [Int] = []
	public static var AdminValidCode = ""

	public static var CurrentLivingMode: Bool
	{
		get { return SdkConfigs.shared.livingDetect && !RtVars.CurrentIsOffLivingDetectTime }
	}
}
