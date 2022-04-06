import Foundation

public enum ReturnFor<TOK, TNO>
{
	case ok( TOK )
	case no( TNO )
}
