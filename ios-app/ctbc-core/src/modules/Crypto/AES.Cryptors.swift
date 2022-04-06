extension AES: Cryptors
{
	public func makeEncryptor() throws -> Cryptor & Updatable
	{
		let worker = try blockMode.worker( blockSize: AES.blockSize, cipherOperation: encrypt )
		if worker is StreamModeWorker
		{
			return try StreamEncryptor( blockSize: AES.blockSize, padding: padding, worker )
		}
		return try BlockEncryptor( blockSize: AES.blockSize, padding: padding, worker )
	}

	public func makeDecryptor() throws -> Cryptor & Updatable
	{
		let cipherOperation: CipherOperationOnBlock = blockMode.options.contains( .useEncryptToDecrypt ) == true ? encrypt : decrypt
		let worker = try blockMode.worker( blockSize: AES.blockSize, cipherOperation: cipherOperation )
		if worker is StreamModeWorker
		{
			return try StreamDecryptor( blockSize: AES.blockSize, padding: padding, worker )
		}
		return try BlockDecryptor( blockSize: AES.blockSize, padding: padding, worker )
	}
}
