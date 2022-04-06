#if arch( x86_64 )
//======================================================================================================
// mock framework for Simulator
//======================================================================================================
import AVFoundation
import CommonCrypto
import CoreData
import CoreML
import Foundation
import struct Foundation.Data
import MobileCoreServices
import Security
import UIKit
import zlib


extension AVDepthData {

	public func convertToDepth() -> AVDepthData
	{
		return self
	}

	public func convertToDisparity() -> AVDepthData
	{
		return self
	}
}

extension CVBuffer {

	public func transformedImage() -> CIImage?
	{
		return nil
	}

	public func deepCopy(withAttributes attributes: [String : Any] = [:]) -> CVPixelBuffer?
	{
		return nil
	}
}

#endif
