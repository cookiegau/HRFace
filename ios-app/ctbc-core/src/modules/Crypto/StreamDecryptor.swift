final class StreamDecryptor: Cryptor, Updatable
{
	private let blockSize: Int
	private var worker: CipherModeWorker
	private let padding: Padding
	private var accumulated = Array<UInt8>()

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
		self.accumulated += bytes

		let toProcess = self.accumulated.prefix( max( self.accumulated.count - self.worker.additionalBufferSize, 0 ) )

		if var finalizingWorker = worker as? FinalizingDecryptModeWorker, isLast == true
		{
			// will truncate suffix if needed
			try finalizingWorker.willDecryptLast( bytes: self.accumulated.slice )
		}

		var processedBytesCount = 0
		var plaintext = Array<UInt8>( reserveCapacity: bytes.count + self.worker.additionalBufferSize )
		for chunk in toProcess.batched( by: self.blockSize )
		{
			plaintext += self.worker.decrypt( block: chunk )
			processedBytesCount += chunk.count
		}

		if var finalizingWorker = worker as? FinalizingDecryptModeWorker, isLast == true
		{
			plaintext = Array( try finalizingWorker.didDecryptLast( bytes: plaintext.slice ) )
		}

		// omit unecessary calculation if not needed
		if self.padding != .noPadding
		{
			self.lastBlockRemainder = plaintext.count.quotientAndRemainder( dividingBy: self.blockSize ).remainder
		}

		if isLast
		{
			// CTR doesn't need padding. Really. Add padding to the last block if really want. but... don't.
			plaintext = self.padding.remove( from: plaintext, blockSize: self.blockSize - self.lastBlockRemainder )
		}

		self.accumulated.removeFirst( processedBytesCount ) // super-slow

		if var finalizingWorker = worker as? FinalizingDecryptModeWorker, isLast == true
		{
			plaintext = Array( try finalizingWorker.finalize( decrypt: plaintext.slice ) )
		}

		return plaintext
	}

	public func seek( to position: Int ) throws
	{
		guard var worker = self.worker as? SeekableModeWorker else
		{
			fatalError( "Not supported" )
		}

		try worker.seek( to: position )
		self.worker = worker
	}
}
