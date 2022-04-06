import Foundation

extension String
{
	func encodeAesCbcPadding5By( key: Data, iv: Data ) throws -> Data
	{
		let data: Array<UInt8> = ( self.data( using: .utf8 )?.bytes )!

		let key: Array<UInt8> = key.bytes
		let iv: Array<UInt8> = iv.bytes

		do
		{
			let encrypted = try AES( key: key, blockMode: CBC( iv: iv ), padding: .pkcs5 ).encrypt( data )
			return Data( encrypted )
		}
		catch { throw Err.WithMessageBy( "encode failed, \( error )" ) }
	}

	func encodeAesCbcPadding5CustomBy( _ keyStr: String ) throws -> Data
	{
		let key = keyStr.data( using: .utf8 )!

		let idxE = key.count - 1
		let idxS = ( idxE - 16 ) + 1

		//print( "idx [\( idxS )]~[\( idxE )] total.count[\( key.count )]" )

		let iv = key.subdata( in: idxS ... idxE )
		//print( "idx [\( idxS )]~[\( idxE )] length[\( iv.count )]" )

		let encoded = try self.encodeAesCbcPadding5By( key: key, iv: iv )

		let data = NSMutableData()
		data.append( iv )
		data.append( encoded )

		return data.copy() as! Data
	}
}
