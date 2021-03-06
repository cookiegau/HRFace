public class BlockDecryptor: Cryptor, Updatable
{
	private let blockSize: Int
	private let padding: Padding
	private var worker: CipherModeWorker
	private var accumulated = Array<UInt8>()

	init( blockSize: Int, padding: Padding, _ worker: CipherModeWorker ) throws
	{
		self.blockSize = blockSize
		self.padding = padding
		self.worker = worker
	}

	public func update( withBytes bytes: ArraySlice<UInt8>, isLast: Bool = false ) throws -> Array<UInt8>
	{
		self.accumulated += bytes

		// If a worker (eg GCM) can combine ciphertext + tag
		// we need to remove tag from the ciphertext.
		if !isLast && self.accumulated.count < self.blockSize + self.worker.additionalBufferSize
		{
			return []
		}

		let accumulatedWithoutSuffix: Array<UInt8>
		if self.worker.additionalBufferSize > 0
		{
			// FIXME: how slow is that?
			accumulatedWithoutSuffix = Array( self.accumulated.prefix( self.accumulated.count - self.worker.additionalBufferSize ) )
		}
		else
		{
			accumulatedWithoutSuffix = self.accumulated
		}

		var processedBytesCount = 0
		var plaintext = Array<UInt8>( reserveCapacity: accumulatedWithoutSuffix.count )
		// Processing in a block-size manner. It's good for block modes, but bad for stream modes.
		for var chunk in accumulatedWithoutSuffix.batched( by: self.blockSize )
		{
			if isLast || ( accumulatedWithoutSuffix.count - processedBytesCount ) >= blockSize
			{
				let isLastChunk = processedBytesCount + chunk.count == accumulatedWithoutSuffix.count

				if isLast, isLastChunk, var finalizingWorker = worker as? FinalizingDecryptModeWorker
				{
					chunk = try finalizingWorker.willDecryptLast( bytes: chunk + accumulated.suffix( worker.additionalBufferSize ) ) // tag size
				}

				if !chunk.isEmpty
				{
					plaintext += worker.decrypt( block: chunk )
				}

				if isLast, isLastChunk, var finalizingWorker = worker as? FinalizingDecryptModeWorker
				{
					plaintext = Array( try finalizingWorker.didDecryptLast( bytes: plaintext.slice ) )
				}

				processedBytesCount += chunk.count
			}
		}
		accumulated.removeFirst( processedBytesCount ) // super-slow

		if isLast
		{
			plaintext = self.padding.remove( from: plaintext, blockSize: self.blockSize )
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

		accumulated = []
	}
}
