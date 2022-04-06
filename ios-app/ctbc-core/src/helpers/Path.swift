#if os( Linux )
import Glibc

let system_glob = Glibc.glob
#else
import Darwin

let system_glob = Darwin.glob
#endif

import Foundation

public struct Path
{
	public static let separator = "/"

	internal let path: String

	internal static let fileManager = FileManager.default

	internal let fileSystemInfo: FileSystemInfo

	public init()
	{
		self.init( "" )
	}

	public init( _ path: String )
	{
		self.init( path, fileSystemInfo: DefaultFileSystemInfo() )
	}

	internal init( _ path: String, fileSystemInfo: FileSystemInfo )
	{
		self.path = path
		self.fileSystemInfo = fileSystemInfo
	}

	internal init( fileSystemInfo: FileSystemInfo )
	{
		self.init( "", fileSystemInfo: fileSystemInfo )
	}

	public init<S: Collection>( components: S ) where S.Iterator.Element == String
	{
		let path: String
		if components.isEmpty
		{
			path = "."
		}
		else if components.first == Path.separator && components.count > 1
		{
			let p = components.joined( separator: Path.separator )
			path = String( p[p.index( after: p.startIndex )...] )
		}
		else
		{
			path = components.joined( separator: Path.separator )
		}
		self.init( path )
	}
}

extension Path: ExpressibleByStringLiteral
{
	public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
	public typealias UnicodeScalarLiteralType = StringLiteralType

	public init( extendedGraphemeClusterLiteral path: StringLiteralType )
	{
		self.init( stringLiteral: path )
	}

	public init( unicodeScalarLiteral path: StringLiteralType )
	{
		self.init( stringLiteral: path )
	}

	public init( stringLiteral value: StringLiteralType )
	{
		self.init( value )
	}
}

extension Path: CustomStringConvertible
{
	public var description: String
	{
		return self.path
	}
}

extension Path
{
	public var string: String
	{
		return self.path
	}

	public var url: URL
	{
		return URL( fileURLWithPath: path )
	}
}

extension Path: Hashable
{
	public func hash( into hasher: inout Hasher )
	{
		hasher.combine( self.path.hashValue )
	}
}

extension Path
{

	public var isAbsolute: Bool
	{
		return path.hasPrefix( Path.separator )
	}

	public var isRelative: Bool
	{
		return !isAbsolute
	}

	public func absolute() -> Path
	{
		if isAbsolute
		{
			return normalize()
		}

		let expandedPath = Path( NSString( string: self.path ).expandingTildeInPath )
		if expandedPath.isAbsolute
		{
			return expandedPath.normalize()
		}

		return ( Path.current + self ).normalize()
	}

	public func normalize() -> Path
	{
		return Path( NSString( string: self.path ).standardizingPath )
	}

	public func abbreviate() -> Path
	{
		let rangeOptions: String.CompareOptions = fileSystemInfo.isFSCaseSensitiveAt( path: self ) ?
				[ .anchored ] : [ .anchored, .caseInsensitive ]
		let home = Path.home.string
		guard let homeRange = self.path.range( of: home, options: rangeOptions ) else { return self }
		let withoutHome = Path( self.path.replacingCharacters( in: homeRange, with: "" ) )

		if withoutHome.path.isEmpty || withoutHome.path == Path.separator
		{
			return Path( "~" )
		}
		else if withoutHome.isAbsolute
		{
			return Path( "~" + withoutHome.path )
		}
		else
		{
			return Path( "~" ) + withoutHome.path
		}
	}

	public func symlinkDestination() throws -> Path
	{
		let symlinkDestination = try Path.fileManager.destinationOfSymbolicLink( atPath: path )
		let symlinkPath = Path( symlinkDestination )
		if symlinkPath.isRelative
		{
			return self + ".." + symlinkPath
		}
		else
		{
			return symlinkPath
		}
	}
}

internal protocol FileSystemInfo
{
	func isFSCaseSensitiveAt( path: Path ) -> Bool
}

internal struct DefaultFileSystemInfo: FileSystemInfo
{
	func isFSCaseSensitiveAt( path: Path ) -> Bool
	{
#if os( Linux )

		return true
#else
		var isCaseSensitive = false


		if let resourceValues = try? path.url.resourceValues( forKeys: [ .volumeSupportsCaseSensitiveNamesKey ] )
		{
			isCaseSensitive = resourceValues.volumeSupportsCaseSensitiveNames ?? isCaseSensitive
		}
		return isCaseSensitive
#endif
	}
}

extension Path
{

	public var lastComponent: String
	{
		return NSString( string: path ).lastPathComponent
	}

	public var lastComponentWithoutExtension: String
	{
		return NSString( string: lastComponent ).deletingPathExtension
	}

	public var components: [String]
	{
		return NSString( string: path ).pathComponents
	}

	public var `extension`: String?
	{
		let pathExtension = NSString( string: path ).pathExtension
		if pathExtension.isEmpty
		{
			return nil
		}

		return pathExtension
	}
}

extension Path
{

	public var exists: Bool
	{
		return Path.fileManager.fileExists( atPath: self.path )
	}

	public var isDirectory: Bool
	{
		var directory = ObjCBool( false )
		guard Path.fileManager.fileExists( atPath: normalize().path, isDirectory: &directory ) else
		{
			return false
		}
		return directory.boolValue
	}

	public var isFile: Bool
	{
		var directory = ObjCBool( false )
		guard Path.fileManager.fileExists( atPath: normalize().path, isDirectory: &directory ) else
		{
			return false
		}
		return !directory.boolValue
	}

	public var isSymlink: Bool
	{
		do
		{
			let _ = try Path.fileManager.destinationOfSymbolicLink( atPath: path )
			return true
		}
		catch
		{
			return false
		}
	}

	public var isReadable: Bool
	{
		return Path.fileManager.isReadableFile( atPath: self.path )
	}

	public var isWritable: Bool
	{
		return Path.fileManager.isWritableFile( atPath: self.path )
	}

	public var isExecutable: Bool
	{
		return Path.fileManager.isExecutableFile( atPath: self.path )
	}

	public var isDeletable: Bool
	{
		return Path.fileManager.isDeletableFile( atPath: self.path )
	}
}

extension Path
{
	public var dateCreated : Date?
	{
		do
		{
			let attrs = try self.url.resourceValues(forKeys: [ .creationDateKey, .nameKey ] )
			return attrs.creationDate
		}
		catch
		{
			return nil
		}
	}
	public var dateModified : Date?
	{
		do
		{
			let attrs = try self.url.resourceValues(forKeys: [ .contentModificationDateKey, .nameKey ] )
			return attrs.contentModificationDate
		}
		catch
		{
			return nil
		}
	}
}

extension Path
{

	public func mkdir() throws -> ()
	{
		try Path.fileManager.createDirectory( atPath: self.path, withIntermediateDirectories: false, attributes: nil )
	}

	public func mkpath() throws -> ()
	{
		try Path.fileManager.createDirectory( atPath: self.path, withIntermediateDirectories: true, attributes: nil )
	}

	public func delete() throws -> ()
	{
		try Path.fileManager.removeItem( atPath: self.path )
	}

	public func move( _ destination: Path ) throws -> ()
	{
		try Path.fileManager.moveItem( atPath: self.path, toPath: destination.path )
	}

	public func copy( _ destination: Path ) throws -> ()
	{
		try Path.fileManager.copyItem( atPath: self.path, toPath: destination.path )
	}

	public func link( _ destination: Path ) throws -> ()
	{
		try Path.fileManager.linkItem( atPath: self.path, toPath: destination.path )
	}

	public func symlink( _ destination: Path ) throws -> ()
	{
		try Path.fileManager.createSymbolicLink( atPath: self.path, withDestinationPath: destination.path )
	}
}

extension Path
{
	public static var current: Path
	{
		get
		{
			return self.init( Path.fileManager.currentDirectoryPath )
		}
		set
		{
			_ = Path.fileManager.changeCurrentDirectoryPath( newValue.description )
		}
	}

	public func chdir( closure: () throws -> () ) rethrows
	{
		let previous = Path.current
		Path.current = self
		defer { Path.current = previous }
		try closure()
	}
}

extension Path
{
	public static var home: Path
	{
		return Path( NSHomeDirectory() )
	}

	public static var temporary: Path
	{
		return Path( NSTemporaryDirectory() )
	}

	public static func processUniqueTemporary() throws -> Path
	{
		let path = temporary + ProcessInfo.processInfo.globallyUniqueString
		if !path.exists
		{
			try path.mkdir()
		}
		return path
	}

	public static func uniqueTemporary() throws -> Path
	{
		let path = try processUniqueTemporary() + UUID().uuidString
		try path.mkdir()
		return path
	}

	public static var document: Path
	{
		let path = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[0]
		return Path( path )
	}
}

extension Path
{
	public func read() throws -> Data
	{
		return try Data( contentsOf: self.url, options: NSData.ReadingOptions( rawValue: 0 ) )
	}

	public func read( _ encoding: String.Encoding = String.Encoding.utf8 ) throws -> String
	{
		return try NSString( contentsOfFile: path, encoding: encoding.rawValue ).substring( from: 0 ) as String
	}

	public func append( _ string: String, encoding: String.Encoding = String.Encoding.utf8 ) throws
	{
		try string.appendToURL( self.url )
	}

	public func appendOrIgnore( _ string: String, encoding: String.Encoding = String.Encoding.utf8 )
	{
		do
		{
			try string.appendToURL( self.url )
		}
		catch
		{
			print( "[appendOrIgnore] \( error.localizedDescription ), url[\( self.url.absoluteString )] data[\( string )]" )
		}
	}
}

extension String
{
	func appendToURL( _ fileURL: URL ) throws
	{
		let data = self.data( using: String.Encoding.utf8 )!
		try data.append( fileURL: fileURL )
	}
}

extension Data
{
	func append( fileURL: URL, options: Data.WritingOptions = .completeFileProtectionUnlessOpen ) throws
	{
		if let fileHandle = FileHandle( forWritingAtPath: fileURL.path )
		{
			defer { fileHandle.closeFile() }
			fileHandle.seekToEndOfFile()
			fileHandle.write( self )
		}
		else
		{
			try write( to: fileURL, options: options )
		}
	}
}

extension Path
{
	public func parent() -> Path
	{
		return self + ".."
	}

	public func children() throws -> [Path]
	{
		return try Path.fileManager.contentsOfDirectory( atPath: path ).map {
			self + Path( $0 )
		}
	}

	public func recursiveChildren() throws -> [Path]
	{
		return try Path.fileManager.subpathsOfDirectory( atPath: path ).map {
			self + Path( $0 )
		}
	}
}

extension Path
{
	public static func find( _ pattern: String ) -> [Path]
	{
		var gt = glob_t()
		let cPattern = strdup( pattern )
		defer {
			globfree( &gt )
			free( cPattern )
		}

		let flags = GLOB_TILDE | GLOB_BRACE | GLOB_MARK
		if system_glob( cPattern, flags, nil, &gt ) == 0
		{
#if os( Linux )
			let matchc = gt.gl_pathc
#else
			let matchc = gt.gl_matchc
#endif
			return ( 0 ..< Int( matchc ) ).compactMap
			{ index in
				if let path = String( validatingUTF8: gt.gl_pathv[index]! )
				{
					return Path( path )
				}

				return nil
			}
		}


		return []
	}

	public func find( _ pattern: String ) -> [Path]
	{
		return Path.find( ( self + pattern ).description )
	}
}

extension Path: Sequence
{
	public struct DirectoryEnumerationOptions: OptionSet
	{
		public let rawValue: UInt

		public init( rawValue: UInt )
		{
			self.rawValue = rawValue
		}

		public static var skipsSubdirectoryDescendants = DirectoryEnumerationOptions( rawValue: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants.rawValue )
		public static var skipsPackageDescendants = DirectoryEnumerationOptions( rawValue: FileManager.DirectoryEnumerationOptions.skipsPackageDescendants.rawValue )
		public static var skipsHiddenFiles = DirectoryEnumerationOptions( rawValue: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles.rawValue )
	}

	public struct PathSequence: Sequence
	{
		private var path: Path
		private var options: DirectoryEnumerationOptions

		init( path: Path, options: DirectoryEnumerationOptions )
		{
			self.path = path
			self.options = options
		}

		public func makeIterator() -> DirectoryEnumerator
		{
			return DirectoryEnumerator( path: path, options: options )
		}
	}

	public struct DirectoryEnumerator: IteratorProtocol
	{
		public typealias Element = Path

		let path: Path
		let directoryEnumerator: FileManager.DirectoryEnumerator?

		init( path: Path, options mask: DirectoryEnumerationOptions = [] )
		{
			let options = FileManager.DirectoryEnumerationOptions( rawValue: mask.rawValue )
			self.path = path
			self.directoryEnumerator = Path.fileManager.enumerator( at: path.url, includingPropertiesForKeys: nil, options: options )
		}

		public func next() -> Path?
		{
			let next = directoryEnumerator?.nextObject()

			if let next = next as? URL
			{
				return Path( next.path )
			}
			return nil
		}

		public func skipDescendants()
		{
			directoryEnumerator?.skipDescendants()
		}
	}

	public func makeIterator() -> DirectoryEnumerator
	{
		return DirectoryEnumerator( path: self )
	}

	public func iterateChildren( options: DirectoryEnumerationOptions = [] ) -> PathSequence
	{
		return PathSequence( path: self, options: options )
	}
}

extension Path: Equatable
{
}

public func ==( lhs: Path, rhs: Path ) -> Bool
{
	return lhs.path == rhs.path
}

public func ~=( lhs: Path, rhs: Path ) -> Bool
{
	return lhs == rhs
			|| lhs.normalize() == rhs.normalize()
}

extension Path: Comparable
{
}

public func <( lhs: Path, rhs: Path ) -> Bool
{
	return lhs.path < rhs.path
}

public func +( lhs: Path, rhs: Path ) -> Path
{
	return lhs.path + rhs.path
}

public func +( lhs: Path, rhs: String ) -> Path
{
	return lhs.path + rhs
}

internal func +( lhs: String, rhs: String ) -> Path
{
	if rhs.hasPrefix( Path.separator )
	{
		return Path( rhs )
	}
	else
	{
		var lSlice = NSString( string: lhs ).pathComponents.fullSlice
		var rSlice = NSString( string: rhs ).pathComponents.fullSlice

		if lSlice.count > 1 && lSlice.last == Path.separator
		{
			lSlice.removeLast()
		}

		lSlice = lSlice.filter { $0 != "." }.fullSlice
		rSlice = rSlice.filter { $0 != "." }.fullSlice


		while lSlice.last != ".." && !lSlice.isEmpty && rSlice.first == ".."
		{
			if lSlice.count > 1 || lSlice.first != Path.separator
			{

				lSlice.removeLast()
			}
			if !rSlice.isEmpty
			{
				rSlice.removeFirst()
			}

			switch ( lSlice.isEmpty, rSlice.isEmpty )
			{
				case ( true, _ ):
					break
				case ( _, true ):
					break
				default:
					continue
			}
		}

		return Path( components: lSlice + rSlice )
	}
}

extension Array
{
	public var fullSlice: ArraySlice<Element>
	{
		return self[self.indices.suffix( from: 0 )]
	}
}

extension URL
{
	public var toPath: Path { return Path( self.path ) }
}

extension String
{
	public var toPath: Path { return Path( self ) }
}
