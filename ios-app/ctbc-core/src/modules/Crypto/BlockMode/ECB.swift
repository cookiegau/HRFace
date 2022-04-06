//  Electronic codebook (ECB)

public struct ECB: BlockMode
{
	public let options: BlockModeOption = .paddingRequired

	public init()
	{
	}

	public func worker( blockSize: Int, cipherOperation: @escaping CipherOperationOnBlock ) throws -> CipherModeWorker
	{
		ECBModeWorker( blockSize: blockSize, cipherOperation: cipherOperation )
	}
}

struct ECBModeWorker: BlockModeWorker
{
	typealias Element = Array<UInt8>
	let cipherOperation: CipherOperationOnBlock
	let blockSize: Int
	let additionalBufferSize: Int = 0

	init( blockSize: Int, cipherOperation: @escaping CipherOperationOnBlock )
	{
		self.blockSize = blockSize
		self.cipherOperation = cipherOperation
	}

	mutating func encrypt( block plaintext: ArraySlice<UInt8> ) -> Array<UInt8>
	{
		guard let ciphertext = cipherOperation( plaintext ) else
		{
			return Array( plaintext )
		}
		return ciphertext
	}

	mutating func decrypt( block ciphertext: ArraySlice<UInt8> ) -> Array<UInt8>
	{
		self.encrypt( block: ciphertext )
	}
}
