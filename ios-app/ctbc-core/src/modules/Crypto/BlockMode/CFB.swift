//  Cipher feedback (CFB)
public struct CFB: BlockMode
{
	public enum Error: Swift.Error
	{
		/// Invalid IV
		case invalidInitializationVector
	}

	public let options: BlockModeOption = [ .initializationVectorRequired, .useEncryptToDecrypt ]
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

		return CFBModeWorker( blockSize: blockSize, iv: self.iv.slice, cipherOperation: cipherOperation )
	}
}

struct CFBModeWorker: BlockModeWorker
{
	let cipherOperation: CipherOperationOnBlock
	let blockSize: Int
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
		guard let ciphertext = cipherOperation( prev ?? iv ) else
		{
			return Array( plaintext )
		}
		self.prev = xor( plaintext, ciphertext.slice )
		return Array( self.prev ?? [] )
	}

	mutating func decrypt( block ciphertext: ArraySlice<UInt8> ) -> Array<UInt8>
	{
		guard let plaintext = cipherOperation( prev ?? iv ) else
		{
			return Array( ciphertext )
		}
		let result: Array<UInt8> = xor( plaintext, ciphertext )
		prev = ciphertext
		return result
	}
}
