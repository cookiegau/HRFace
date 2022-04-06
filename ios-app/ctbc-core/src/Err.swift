import Foundation

public enum Err: Swift.Error
{
	case Initialize( _ msg: String )
	case WithMessageBy( _ msg: String )
	case WithDataBy( _ data: [String: Any] )
}

extension Err
{
	public var data: [String: Any]?
	{
		get
		{
			if case let .WithDataBy( data ) = self { return data }
			return nil
		}
	}

	public var message: String?
	{
		get
		{
			switch( self )
			{
				case .Initialize( let msg ):
					return msg

				case .WithMessageBy( let msg ):
					return msg

				case .WithDataBy( let data ):
					return data["message"] as? String
			}
		}
	}
}


extension Err: LocalizedError
{
    public var errorDescription: String?
	{
		let msg = self.message ?? "Unknown"
		return NSLocalizedString( msg, comment: "CTBC.Err" )
    }
}
