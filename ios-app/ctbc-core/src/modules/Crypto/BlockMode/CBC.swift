//  Cipher-block chaining (CBC)
public struct CBC: BlockMode
{
	public enum Error: Swift.Error
	{
		/// Invalid IV
		case invalidInitializationVector
	}

	public let options: BlockModeOption = [ .initializationVectorRequired, .paddingRequired ]
	private let iv: Array<UInt8>

	public init( iv: Array<UInt8> )
	{
		self.iv = iv
	}

	public func worker( blockSize: Int, cipherOperation: @escaping CipherOperationOnBlock ) throws -> CipherModeWorker
	{
		if self.iv.count != blockSize
		{
			throw Error.invalidInitializationVector
		}

		return CBCModeWorker( blockSize: blockSize, iv: self.iv.slice, cipherOperation: cipherOperation )
	}
}

struct CBCModeWorker: BlockModeWorker
{
	let cipherOperation: CipherOperationOnBlock
	var blockSize: Int
	let additionalBufferSize: Int = 0
	private let iv: ArraySlice<UInt8>
	private var prev: ArraySlice<UInt8>?

	init( blockSize: Int, iv: ArraySlice<UInt8>, cipherOperation: @escaping CipherOperationOnBlock )
	{
		self.blockSize = blockSize
		self.iv = iv
		self.cipherOperation = cipherOperation
	}

	mutating func encrypt( block plaintext: ArraySlice<UInt8> ) -> Array<UInt8>
	{
		guard let ciphertext = cipherOperation( xor( prev ?? iv, plaintext ) ) else
		{
			return Array( plaintext )
		}
		self.prev = ciphertext.slice
		return ciphertext
	}

	mutating func decrypt( block ciphertext: ArraySlice<UInt8> ) -> Array<UInt8>
	{
		guard let plaintext = cipherOperation( ciphertext ) else
		{
			return Array( ciphertext )
		}
		let result: Array<UInt8> = xor( prev ?? self.iv, plaintext )
		self.prev = ciphertext
		return result
	}
}
