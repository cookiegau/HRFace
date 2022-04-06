import Foundation
import os
import os.log

public class Log
{
	public typealias OnIntervalLogs = ( _ logs: inout ThreadSafeArray<LogMessage>, _ isCrash: Bool ) throws -> Void
	public typealias OnLog = ( _ log: LogMessage ) throws -> Void
	public typealias OnLogFilter = ( _ log: Log.LogMessage ) -> Bool

	public enum Level: Int
	{
		case Debug = 1
		case Info = 2
		case Warn = 3
		case Error = 4
		case Fatal = 5

		var string: String
		{
			switch self
			{
				case .Debug: return "DEBUG"
				case .Info:  return "INFO "
				case .Warn:  return "WARN "
				case .Error: return "ERROR"
				case .Fatal: return "FATAL"
			}
		}

		var logType: OSLogType
		{
			switch self
			{
				case .Debug: return .debug
				case .Info:  return .info
				case .Warn:  return .error
				case .Error: return .error
				case .Fatal: return .fault
			}
		}
	}

	public class LogMessage: CustomStringConvertible
	{
		public var time: Date
		public var lv: Level
		public var msg: String

		public var timeStr: String
		{
			get { return formatter.string( from: self.time ) }
		}

		init( _ lv: Level, _ msg: String )
		{
			self.time = Date()
			self.lv = lv
			self.msg = msg
		}

		init( _ time: Date, _ lv: Level, _ msg: String )
		{
			self.time = time
			self.lv = lv
			self.msg = msg
		}

		public func ToLineBy( _ now: Date, _ level: Level, _ message: String ) -> String
		{
			return "\( formatter.string( from: now ) )|\( level.string )| \( message )"
		}

		public var string: String
		{
			get { return String( describing: self ) }
		}

		public var description: String
		{
			return self.ToLineBy( self.time, self.lv, self.msg )
		}
	}

//====================================================================================
// static variables
//====================================================================================
	static let osLog = OSLog( subsystem: "hrface", category: "hrface" )

	static let queueKey = DispatchSpecificKey<UnsafeMutableRawPointer>()
	static let queueValue = UnsafeMutableRawPointer.allocate( byteCount: 1, alignment: 1 )
	static let lockQueue =
	{
		() -> DispatchQueue in
		let queue = DispatchQueue( label: "logger" )
		queue.setSpecific( key: queueKey, value: queueValue )
		return queue
	}()

	private static func runAtQueueBy( _ action: () -> Void )
	{
		if ( DispatchQueue.getSpecific( key: Log.queueKey ) == Log.queueValue )
		{
			action()
		}
		else
		{
			lockQueue.sync { action() }
		}
	}

	static var tempLogs: ThreadSafeArray<LogMessage> = ThreadSafeArray()

	static var timer: Timer? = nil
	static var onIntervalEvent: OnIntervalLogs? = nil
	static var onLog: OnLog? = nil

	static var formatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyyMMddHHmmss.SSS"
		return df
	}()

	public static func ToDateTimeStringBy( _ date: Date ) -> String
	{
		return formatter.string( from: date )
	}

	public static func GetDirForLogs( _ dirName: String ) throws -> Path
	{
		let dir = Path.document + "\( dirName )"

		if ( dir.exists && !dir.isDirectory ) { try dir.delete() }
		if ( !dir.exists ) { try dir.mkdir() }
		if ( !dir.isWritable ) { throw Err.Initialize( "The LogDir[\( dir.string )] not writable" ) }

		Log.Debug( "LogPath: \( dir.string )" )

		return dir
	}

	public static func AppendTodayCrashLogBy( _ message: String )
	{
		do
		{
			let pathToday = try GetDirForLogs( "Logs" ) + "\( Date().toString( format: "yyyyMMdd" ) ).log"
			pathToday.appendOrIgnore( message )
		}
		catch
		{
			let pathToday = Path.document + "\( Date().toString( format: "yyyyMMdd" ) )-crash.log"
			pathToday.appendOrIgnore( message )
		}
	}

//====================================================================================
// events
//====================================================================================
	public static func TriggerInterval( _ isCrash: Bool = false )
	{
		guard let event = onIntervalEvent else { return }

		let action =
		{
			do
			{
				try event( &tempLogs, isCrash )
			}
			catch
			{
				Log.AppendTodayCrashLogBy( "[App] onCrash invoke LogInterval Failed...\( error )" )
			}
		}

		if ( isCrash )
		{
			action()
		}
		else
		{
			runAtQueueBy { action() }
		}
	}

	public static func SetOnIntervalBy( _ seconds: TimeInterval, _ onInterval: @escaping OnIntervalLogs ) throws
	{
		guard Log.onIntervalEvent == nil else { throw Err.Initialize( "[Log] 已經設定過OnInterval事件" ) }

		do
		{
			//Log.Debug( "[Log] init onIntervalLogs..." )
			try onInterval( &tempLogs, false )
		}
		catch { throw Err.Initialize( "[Log] init onIntervalLogs Failed, \( error.localizedDescription )" ) }

		Log.onIntervalEvent = onInterval;
		timer = Timer.scheduledTimer( withTimeInterval: seconds, repeats: true )
		{
			_ in
			Log.TriggerInterval()
		}
	}

	public static func SetOnLogBy( _ onLog: @escaping OnLog )
	{
		guard Log.onLog == nil else
		{
			Log.Warn( "已經設定過OnLog事件" )
			return
		}

		Log.onLog = onLog
	}

//====================================================================================
// core functions
//====================================================================================

	static var prevDT: Date = Date()
	static var prevStr: String = ""

	public static func LogBy( _ level: Level, _ message: String ) -> String
	{
		let msg = LogMessage( level, message )

		runAtQueueBy
		{
			let now = Date()
			let checkSecs = now.timeIntervalSince( prevDT )
			//print( "[Log] checkSecs[\( checkSecs )] equal[\( prevStr == message )] prevStr[\( prevStr )] message[\( message )]" )
			if ( prevStr != message || checkSecs >= 1 )
			{
				os_log( "%{public}@|%{public}@| %{public}@", log: osLog, type: level.logType, msg.timeStr, level.string, message )

				do { try onLog?( msg ) }
				catch
				{
					os_log( "[Log:OnLog] Fatal On OnLog Event, %{public}@", log: osLog, type: .error, error.localizedDescription )
				}

				tempLogs.append( msg )

				prevDT = now
				prevStr = message
			}
		}

		return String( describing: msg )
	}

	public static func LogBy( _ level: Level, _ message: String, _ objects: Encodable... ) -> String
	{
		LogBy( level, message, objects )
	}

	private static func LogBy( _ level: Level, _ message: String, _ objects: [Encodable] ) -> String
	{
		var strs: [String] = []
		for item in objects { strs.append( item.toJson ) }

		if ( objects.count >= 1 )
		{
			return LogBy( level, "\( message ), \( strs.joined( separator: "," ) )" )
		}
		else
		{
			return LogBy( level, message )
		}
	}

//====================================================================================
// shortcuts
//====================================================================================
	public static func Debug( _ message: String, _ objects: Encodable... )
	{
		_ = LogBy( .Debug, message, objects )
	}

	public static func Info( _ message: String, _ objects: Encodable... )
	{
		_ = LogBy( .Info, message, objects )
	}

	public static func Warn( _ message: String, _ objects: Encodable... )
	{
		_ = LogBy( .Warn, message, objects )
	}

	public static func Error( _ message: String, _ objects: Encodable... )
	{
		_ = LogBy( .Error, message, objects )
	}

	public static func Fatal( _ message: String, _ objects: Encodable... )
	{
		_ = LogBy( .Fatal, message, objects )
	}

	public static func GetCallStack() -> String
	{
		var message = ""
		message += "[thread] \( Thread.current )\n"
		message += "[infos] returnAddresses: \( Thread.callStackReturnAddresses )\n"
		message += "[stack] callStackSymbols: \n\( Thread.callStackSymbols.joined( separator: "\n" ) )\n"

		return message
	}

	public static func HandleSignalBy( _ signal: Int32, _ code: String = "unknown" )
	{
		let message = "[App:Crash] signal[\( signal )] code[\( code )]\n\( GetCallStack() )"

		os_log( "%{public}@", log: osLog, type: .fault, message )

		Log.Error( message )

		NSSetUncaughtExceptionHandler( nil )
		Log.TriggerInterval( true )

		KillApp( signal )
	}

	public static func KillApp( _ code: Int32 )
	{
		signal( SIGABRT, SIG_DFL )
		signal( SIGILL, SIG_DFL )
		signal( SIGSEGV, SIG_DFL )
		signal( SIGFPE, SIG_DFL )
		signal( SIGBUS, SIG_DFL )
		signal( SIGPIPE, SIG_DFL )
		signal( SIGTRAP, SIG_DFL )

		//exit( code )
		//kill(getpid(), SIGKILL)
	}
}

extension Array where Element == Log.LogMessage
{
	public func JoinLines( _ filter: Log.OnLogFilter? = nil ) -> String
	{
		var strs: [String] = []

		self.forEach
		{
			log in

			if let funcFilter = filter
			{
				let need = funcFilter( log )
				if ( need == false ) { return }
			}

			strs.append( log.string )
		}

		return strs.joined( separator: "\n" )
	}
}
