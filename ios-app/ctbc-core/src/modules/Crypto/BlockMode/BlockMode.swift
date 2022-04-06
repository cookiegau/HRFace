public typealias CipherOperationOnBlock = ( _ block: ArraySlice<UInt8> ) -> Array<UInt8>?

public protocol BlockMode
{
	var options: BlockModeOption { get }
	//TODO: doesn't have to be public
	func worker( blockSize: Int, cipherOperation: @escaping CipherOperationOnBlock ) throws -> CipherModeWorker
}

typealias StreamMode = BlockMode
