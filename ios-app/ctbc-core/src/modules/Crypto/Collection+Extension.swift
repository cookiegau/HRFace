extension Collection where Self.Element == UInt8, Self.Index == Int
{
	// Big endian order
	func toUInt32Array() -> Array<UInt32>
	{
		guard !isEmpty else
		{
			return []
		}

		let c = strideCount( from: startIndex, to: endIndex, by: 4 )
		return Array<UInt32>( unsafeUninitializedCapacity: c )
		{ buf, count in
			var counter = 0
			for idx in stride( from: startIndex, to: endIndex, by: 4 )
			{
				let val = UInt32( bytes: self, fromIndex: idx ).bigEndian
				buf[counter] = val
				counter += 1
			}
			count = counter
			assert( counter == c )
		}
	}

	// Big endian order
	func toUInt64Array() -> Array<UInt64>
	{
		guard !isEmpty else
		{
			return []
		}

		let c = strideCount( from: startIndex, to: endIndex, by: 8 )
		return Array<UInt64>( unsafeUninitializedCapacity: c )
		{ buf, count in
			var counter = 0
			for idx in stride( from: startIndex, to: endIndex, by: 8 )
			{
				let val = UInt64( bytes: self, fromIndex: idx ).bigEndian
				buf[counter] = val
				counter += 1
			}
			count = counter
			assert( counter == c )
		}
	}
}

private func strideCount( from: Int, to: Int, by: Int ) -> Int
{
	let count = to - from
	return count / by + ( count % by > 0 ? 1 : 0 )
}
