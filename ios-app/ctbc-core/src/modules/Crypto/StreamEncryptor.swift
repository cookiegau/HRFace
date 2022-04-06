final class StreamEncryptor: Cryptor, Updatable
{
	private let blockSize: Int
	private var worker: CipherModeWorker
	private let padding: Padding

	private var lastBlockRemainder = 0

	init( blockSize: Int, padding: Padding, _ worker: CipherModeWorker ) throws
	{
		self.blockSize = blockSize
		self.padding = padding
		self.worker = worker
	}

	// MARK: Updatable

	public func update( withBytes bytes: ArraySlice<UInt8>, isLast: Bool ) throws -> Array<UInt8>
	{
		var accumulated = Array( bytes )
		if isLast
		{
			// CTR doesn't need padding. Really. Add padding to the last block if really want. but... don't.
			accumulated = self.padding.add( to: accumulated, blockSize: self.blockSize - self.lastBlockRemainder )
		}

		var encrypted = Array<UInt8>( reserveCapacity: bytes.count )
		for chunk in accumulated.batched( by: self.blockSize )
		{
			encrypted += self.worker.encrypt( block: chunk )
		}

		// omit unecessary calculation if not needed
		if self.padding != .noPadding
		{
			self.lastBlockRemainder = encrypted.count.quotientAndRemainder( dividingBy: self.blockSize ).remainder
		}

		if var finalizingWorker = worker as? FinalizingEncryptModeWorker, isLast == true
		{
			encrypted = Array( try finalizingWorker.finalize( encrypt: encrypted.slice ) )
		}

		return encrypted
	}

	func seek( to: Int ) throws
	{
		fatalError( "Not supported" )
	}
}
