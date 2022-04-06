/// Array of bytes. Caution: don't use directly because generic is slow.
///
/// - parameter value: integer value
/// - parameter length: length of output array. By default size of value type
///
/// - returns: Array of bytes
@_specialize( where T == Int )
@_specialize( where T == UInt )
@_specialize( where T == UInt8 )
@_specialize( where T == UInt16 )
@_specialize( where T == UInt32 )
@_specialize( where T == UInt64 )
func arrayOfBytes<T: FixedWidthInteger>( value: T, length totalBytes: Int = MemoryLayout<T>.size ) -> Array<UInt8>
{
	let valuePointer = UnsafeMutablePointer<T>.allocate( capacity: 1 )
	valuePointer.pointee = value

	let bytesPointer = UnsafeMutablePointer<UInt8>( OpaquePointer( valuePointer ) )
	var bytes = Array<UInt8>( repeating: 0, count: totalBytes )
	for j in 0 ..< min( MemoryLayout<T>.size, totalBytes )
	{
		bytes[totalBytes - 1 - j] = ( bytesPointer + j ).pointee
	}

	valuePointer.deinitialize( count: 1 )
	valuePointer.deallocate()

	return bytes
}
