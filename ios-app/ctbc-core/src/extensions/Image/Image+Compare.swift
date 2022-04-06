import UIKit

public extension UIImage
{
	func ComparePixelMatchPercentageBy( _ imgR: UIImage ) throws -> Float
	{
		guard let imgCGL = self.cgImage, let imgCGR = imgR.cgImage else { throw Err.Initialize( "cannot get cgImage from Images" ) }
		guard let imgCSL = imgCGL.colorSpace, let imgCSR = imgCGR.colorSpace else { throw Err.Initialize( "cannot get color space from cgimage" ) }
		if imgCGL.width != imgCGR.width || imgCGL.height != imgCGR.height { throw Err.Initialize( "cannot compare different size images" ) }

		let size = CGSize( width: imgCGL.width, height: imgCGL.height )
		let w = Int( size.width )
		let h = Int( size.height )
		let countPixels = Int( size.width * size.height ) //230400
		let bytesPR = min( imgCGL.bytesPerRow, imgCGR.bytesPerRow ) //1440
		if ( MemoryLayout<UInt32>.stride != ( bytesPR / Int( size.width ) ) )
		{
			Log.Warn( "[UIImage] compare size[\( ( bytesPR / Int( size.width ) ) )] not equal to UInt32[\( MemoryLayout<UInt32>.stride )]" )
			return 0.0
		}

		let pixelsL = UnsafeMutablePointer<UInt32>.allocate( capacity: countPixels )
		let pixelsR = UnsafeMutablePointer<UInt32>.allocate( capacity: countPixels )
		let pixelsRawL = UnsafeMutableRawPointer( pixelsL )
		let pixelsRawR = UnsafeMutableRawPointer( pixelsR )

		let bmpInfo = CGBitmapInfo( rawValue: CGImageAlphaInfo.premultipliedLast.rawValue )
		guard let ctxL = CGContext( data: pixelsRawL, width: w, height: h, bitsPerComponent: imgCGL.bitsPerComponent, bytesPerRow: bytesPR, space: imgCSL, bitmapInfo: bmpInfo.rawValue ) else
		{
			pixelsL.deallocate()
			pixelsR.deallocate()
			throw Err.Initialize( "cannot init cg-context from imageL" )
		}
		guard let ctxR = CGContext( data: pixelsRawR, width: Int( size.width ), height: Int( size.height ), bitsPerComponent: imgCGR.bitsPerComponent, bytesPerRow: bytesPR, space: imgCSR, bitmapInfo: bmpInfo.rawValue ) else
		{
			pixelsL.deallocate()
			pixelsR.deallocate()
			throw Err.Initialize( "cannot init cg-context from imageR" )
		}

		ctxL.draw( imgCGL, in: CGRect( origin: .zero, size: size ) )
		ctxR.draw( imgCGR, in: CGRect( origin: .zero, size: size ) )

		var countMatch = 0
		let bufferL = UnsafeBufferPointer( start: pixelsL, count: countPixels )
		let bufferR = UnsafeBufferPointer( start: pixelsR, count: countPixels )

		for idx in 0 ..< countPixels where bufferL[idx] == bufferR[idx]
		{
			countMatch += 1
		}

		pixelsL.deallocate()
		pixelsR.deallocate()

		return ( Float( countMatch ) / Float( countPixels ) )
	}
}
