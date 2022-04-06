public enum Bit: Int
{
	case zero
	case one
}

extension Bit
{
	func inverted() -> Bit
	{
		self == .zero ? .one : .zero
	}
}
