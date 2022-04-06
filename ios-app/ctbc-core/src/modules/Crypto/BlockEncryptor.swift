final class BlockEncryptor: Cryptor, Updatable
{
	private let blockSize: Int
	private var worker: CipherModeWorker
	private let padding: Padding
	// Accumulated bytes. Not all processed bytes.
	private var accumulated = Array<UInt8>( reserveCapacity: 16 )

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

		if isLast
		{
			self.accumulated = self.padding.add( to: self.accumulated, blockSize: self.blockSize )
		}

		var encrypted = Array<UInt8>( reserveCapacity: accumulated.count )
		for chunk in self.accumulated.batched( by: self.blockSize )
		{
			if isLast || chunk.count == self.blockSize
			{
				encrypted += self.worker.encrypt( block: chunk )
			}
		}

		// Stream encrypts all, so it removes all elements
		self.accumulated.removeFirst( encrypted.count )

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
