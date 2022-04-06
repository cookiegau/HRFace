import Foundation

func perf( _ text: String, closure: () -> Void )
{
	let measurementStart = Date()

	closure()

	let measurementStop = Date()
	let executionTime = measurementStop.timeIntervalSince( measurementStart )

	print( "\( text ) \( executionTime )" )
}
