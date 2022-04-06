public struct BlockModeOption: OptionSet
{
	public let rawValue: Int

	public init( rawValue: Int )
	{
		self.rawValue = rawValue
	}

	static let none = BlockModeOption( rawValue: 1 << 0 )
	static let initializationVectorRequired = BlockModeOption( rawValue: 1 << 1 )
	static let paddingRequired = BlockModeOption( rawValue: 1 << 2 )
	static let useEncryptToDecrypt = BlockModeOption( rawValue: 1 << 3 )
}
