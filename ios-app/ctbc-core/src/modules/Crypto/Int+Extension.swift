#if canImport( Darwin )
import Darwin
#else
import Glibc
#endif

extension FixedWidthInteger
{
	@_transparent
	func bytes( totalBytes: Int = MemoryLayout<Self>.size ) -> Array<UInt8>
	{
		arrayOfBytes( value: self.littleEndian, length: totalBytes )
		// TODO: adjust bytes order
		// var value = self.littleEndian
		// return withUnsafeBytes(of: &value, Array.init).reversed()
	}
}
