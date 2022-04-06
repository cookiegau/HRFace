import Foundation

public class ThreadSafeArray<T>
{
	private var array: [T] = []
	private let queue = DispatchQueue( label: "ThreadSafeArrayAccess", attributes: .concurrent )

	public init()
	{
	}

	public var count: Int
	{
		var count = 0
		self.queue.sync { count = self.array.count }
		return count
	}

	public func first() -> T?
	{
		var element: T?
		self.queue.sync
		{
			if !self.array.isEmpty { element = self.array[0] }
		}
		return element
	}

	public subscript( index: Int ) -> T
	{
		set { self.queue.async( flags: .barrier ) { self.array[index] = newValue } }
		get
		{
			var element: T!
			self.queue.sync { element = self.array[index] }
			return element
		}
	}

	public func getBy<TR>( _ fn: ( _ array: inout [T] ) -> TR ) -> TR
	{
		var ret: TR!
		self.queue.sync { ret = fn( &self.array ) }
		return ret
	}

	public func clone() -> [T]
	{
		return self.array.map { $0 }
	}

	public func append( _ item: T )
	{
		self.queue.async( flags: .barrier )
		{
			self.array.append( item )
		}
	}

	public func removeAtIndex( _ idx: Int )
	{
		self.queue.async( flags: .barrier ) { self.array.remove( at: idx ) }
	}

	public func removeAll()
	{
		self.queue.async( flags: .barrier ) { self.array.removeAll() }
	}
}
