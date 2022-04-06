import Foundation

public class NetUtils
{
	public enum NetworkType: String
	{
		case wifi = "en0"
		case cellular = "pdp_ip0"
		case ipv4 = "ipv4"
		case ipv6 = "ipv6"
	}

	public static func GetAvailableIPv4() -> String?
	{
		var ip: String?

		var ifaddr: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs( &ifaddr ) == 0 else { return nil }
		guard let firstAddr = ifaddr else { return nil }

		for ptr in sequence( first: firstAddr, next: { $0.pointee.ifa_next } )
		{
			let interface = ptr.pointee
			let addrFamily = interface.ifa_addr.pointee.sa_family
			if addrFamily == UInt8( AF_INET )
			{
				var hostname = [ CChar ]( repeating: 0, count: Int( NI_MAXHOST ) )
				getnameinfo( interface.ifa_addr, socklen_t( interface.ifa_addr.pointee.sa_len ), &hostname, socklen_t( hostname.count ), nil, socklen_t( 0 ), NI_NUMERICHOST )

				let address = String( cString: hostname )
				if ( !address.hasPrefix( "127.0.0.1" ) && ip == nil ) { ip = address }
			}
		}

		freeifaddrs( ifaddr )

		return ip
	}

	public static func GetAddressBy( _ network: NetworkType ) -> String?
	{
		var ip: String?

		var ifaddr: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs( &ifaddr ) == 0 else { return nil }
		guard let firstAddr = ifaddr else { return nil }

		for ptr in sequence( first: firstAddr, next: { $0.pointee.ifa_next } )
		{
			let interface = ptr.pointee
			let addrFamily = interface.ifa_addr.pointee.sa_family
			if addrFamily == UInt8( AF_INET ) || addrFamily == UInt8( AF_INET6 )
			{
				let name = String( cString: interface.ifa_name )
				if name == network.rawValue
				{
					var hostname = [ CChar ]( repeating: 0, count: Int( NI_MAXHOST ) )
					getnameinfo( interface.ifa_addr, socklen_t( interface.ifa_addr.pointee.sa_len ), &hostname, socklen_t( hostname.count ), nil, socklen_t( 0 ), NI_NUMERICHOST )

					ip = String( cString: hostname )
					break
				}
			}
		}

		freeifaddrs( ifaddr )
		return ip
	}
}
