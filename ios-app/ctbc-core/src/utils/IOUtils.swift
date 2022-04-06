import Foundation

public class IOUtils
{
	public static func GetTmpFolder( _ dirName: String? = nil ) -> URL
	{
		var pathTmpDir = NSTemporaryDirectory();
		if ( dirName != nil ) { pathTmpDir = pathTmpDir.stringByAppendingPathComponent( dirName! ) }
		do
		{
			if ( dirName != nil ) { try fm.createDirectory( atPath: pathTmpDir, withIntermediateDirectories: true, attributes: nil ); }
		}
		catch {}

		return URL( fileURLWithPath: pathTmpDir );
	}

	static var fm = FileManager.default;

	public static func GetFolders( _ rootPath: String, _ includeChildren: Bool = false ) -> [String]
	{
		return GetPaths( rootPath, includeChildren, onlyFolder: true )
	}

	public static func GetFiles( _ path: String, _ includeChildren: Bool = false ) -> [String]
	{
		return GetPaths( path, includeChildren, onlyFile: true )
	}

	public static func GetFolderAndFiles( _ path: String, _ includeChildren: Bool = false ) -> [String]
	{
		return GetPaths( path, includeChildren )
	}

	// Relative Path "/out/001.jpg"
	public static func GetPaths( _ path: String, _ includeChildren: Bool = false, onlyFolder: Bool = false, onlyFile: Bool = false ) -> [String]
	{
		let baseUrl = URL( fileURLWithPath: path, isDirectory: true ).resolvingSymlinksInPath()
		return GetPaths( baseUrl, includeChildren, onlyFolder: onlyFolder, onlyFile: onlyFile )
	}

	public static func GetPaths( _ baseUrl: URL, _ includeChildren: Bool = false, onlyFolder: Bool = false, onlyFile: Bool = false ) -> [String]
	{
		var keys: [URLResourceKey] = []
		var opts: FileManager.DirectoryEnumerationOptions = [ .skipsHiddenFiles, .skipsPackageDescendants ]

		let allowFI = onlyFile || ( !onlyFile && !onlyFolder );
		let allowFO = onlyFolder || ( !onlyFile && !onlyFolder );

		if ( !includeChildren ) { opts.insert( .skipsSubdirectoryDescendants ) }
		if ( allowFI ) { keys.append( .nameKey ) }
		if ( allowFO ) { keys.append( .isDirectoryKey ) }


		let enumerator = fm.enumerator( at: baseUrl, includingPropertiesForKeys: keys, options: opts, errorHandler: nil )

		var paths = [ String ]();
		while let fileUrl = enumerator?.nextObject() as? URL
		{
			var isDir: ObjCBool = false;
			let exist = fm.fileExists( atPath: fileUrl.path, isDirectory: &isDir )
			if ( !exist ) { continue }

			let pathFile = fileUrl.path
					.replacingOccurrences( of: baseUrl.path, with: "" )
					.replacingOccurrences( of: "//", with: "/" )

			if ( allowFO && isDir.boolValue ) { paths.append( pathFile ) }
			if ( allowFI && !isDir.boolValue ) { paths.append( pathFile ) }
		}


		return paths;
	}
}
