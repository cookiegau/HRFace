/// A type that supports incremental updates. For example Digest or Cipher may be updatable
/// and calculate result incerementally.
public protocol Updatable
{
	/// Update given bytes in chunks.
	///
	/// - parameter bytes: Bytes to process.
	/// - parameter isLast: Indicate if given chunk is the last one. No more updates after this call.
	/// - returns: Processed partial result data or empty array.
	mutating func update( withBytes bytes: ArraySlice<UInt8>, isLast: Bool ) throws -> Array<UInt8>

	/// Update given bytes in chunks.
	///
	/// - Parameters:
	///   - bytes: Bytes to process.
	///   - isLast: Indicate if given chunk is the last one. No more updates after this call.
	///   - output: Resulting bytes callback.
	/// - Returns: Processed partial result data or empty array.
	mutating func update( withBytes bytes: ArraySlice<UInt8>, isLast: Bool, output: ( _ bytes: Array<UInt8> ) -> Void ) throws
}

extension Updatable
{
	public mutating func update( withBytes bytes: ArraySlice<UInt8>, isLast: Bool = false, output: ( _ bytes: Array<UInt8> ) -> Void ) throws
	{
		let processed = try update( withBytes: bytes, isLast: isLast )
		if !processed.isEmpty
		{
			output( processed )
		}
	}

	public mutating func update( withBytes bytes: ArraySlice<UInt8>, isLast: Bool = false ) throws -> Array<UInt8>
	{
		try self.update( withBytes: bytes, isLast: isLast )
	}

	public mutating func update( withBytes bytes: Array<UInt8>, isLast: Bool = false ) throws -> Array<UInt8>
	{
		try self.update( withBytes: bytes.slice, isLast: isLast )
	}

	public mutating func update( withBytes bytes: Array<UInt8>, isLast: Bool = false, output: ( _ bytes: Array<UInt8> ) -> Void ) throws
	{
		try self.update( withBytes: bytes.slice, isLast: isLast, output: output )
	}

	/// Finish updates. This may apply padding.
	/// - parameter bytes: Bytes to process
	/// - returns: Processed data.
	public mutating func finish( withBytes bytes: ArraySlice<UInt8> ) throws -> Array<UInt8>
	{
		try self.update( withBytes: bytes, isLast: true )
	}

	public mutating func finish( withBytes bytes: Array<UInt8> ) throws -> Array<UInt8>
	{
		try self.finish( withBytes: bytes.slice )
	}

	/// Finish updates. May add padding.
	///
	/// - Returns: Processed data
	/// - Throws: Error
	public mutating func finish() throws -> Array<UInt8>
	{
		try self.update( withBytes: [], isLast: true )
	}

	/// Finish updates. This may apply padding.
	/// - parameter bytes: Bytes to process
	/// - parameter output: Resulting data
	/// - returns: Processed data.
	public mutating func finish( withBytes bytes: ArraySlice<UInt8>, output: ( _ bytes: Array<UInt8> ) -> Void ) throws
	{
		let processed = try update( withBytes: bytes, isLast: true )
		if !processed.isEmpty
		{
			output( processed )
		}
	}

	public mutating func finish( withBytes bytes: Array<UInt8>, output: ( _ bytes: Array<UInt8> ) -> Void ) throws
	{
		try self.finish( withBytes: bytes.slice, output: output )
	}

	/// Finish updates. May add padding.
	///
	/// - Parameter output: Processed data
	/// - Throws: Error
	public mutating func finish( output: ( Array<UInt8> ) -> Void ) throws
	{
		try self.finish( withBytes: [], output: output )
	}
}
