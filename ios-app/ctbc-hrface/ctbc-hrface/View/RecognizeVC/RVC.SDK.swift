import AVFoundation
import CoreData
import Network
import QuartzCore
import UIKit
import Vision

import CtbcCore

#if !arch( x86_64 )
import FaceCore
#endif

extension RecognizeVC: CTBCFaceDetectionDelegate
{
	func happy( _ info: FaceInfo )
	{
		Log.Debug( "[Sdk:happy] notice info[\( info.jsonStr )]" )

		if ( !info.is_happy_detect )
		{
			Log.Warn( "[Sdk:happy] get wrong is_happy_detect info[\( info.jsonStr )]" )
		}
		else
		{
			if ( RtVars.CurrentLivingMode && !info.is_living )
			{
				Log.Warn( "[Sdk:happy] get not living info[\( info.jsonStr )], ignore punch" )
				return
			}

			let id = ( info.id as String? ) ?? ""
			let uuid = ( info.uuid as String? ) ?? ""

			if ( id.length <= 0 || uuid.length <= 0 )
			{
				Log.Warn( "[Sdk:happy] get wrong event info, id[\( id )] uuid[\( uuid )], info[\( info.jsonStr )]" )
			}
			else
			{
				Api.SendPunchBy( id, uuid )
				{
					RtVars.LastPunch = Date()
					RtVars.LastPunchId = id

					info.is_clock_in = true
				}
			}
		}
	}
}
