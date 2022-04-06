protocol BlockCipher: Cipher
{
	static var blockSize: Int { get }
}
