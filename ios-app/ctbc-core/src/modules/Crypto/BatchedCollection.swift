struct BatchedCollectionIndex<Base: Collection>
{
	let range: Range<Base.Index>
}

extension BatchedCollectionIndex: Comparable
{
	static func ==<Base>( lhs: BatchedCollectionIndex<Base>, rhs: BatchedCollectionIndex<Base> ) -> Bool
	{
		lhs.range.lowerBound == rhs.range.lowerBound
	}

	static func <<Base>( lhs: BatchedCollectionIndex<Base>, rhs: BatchedCollectionIndex<Base> ) -> Bool
	{
		lhs.range.lowerBound < rhs.range.lowerBound
	}
}

protocol BatchedCollectionType: Collection
{
	associatedtype Base: Collection
}

struct BatchedCollection<Base: Collection>: Collection
{
	let base: Base
	let size: Int
	typealias Index = BatchedCollectionIndex<Base>

	private func nextBreak( after idx: Base.Index ) -> Base.Index
	{
		self.base.index( idx, offsetBy: self.size, limitedBy: self.base.endIndex ) ?? self.base.endIndex
	}

	var startIndex: Index
	{
		Index( range: self.base.startIndex ..< self.nextBreak( after: self.base.startIndex ) )
	}

	var endIndex: Index
	{
		Index( range: self.base.endIndex ..< self.base.endIndex )
	}

	func index( after idx: Index ) -> Index
	{
		Index( range: idx.range.upperBound ..< self.nextBreak( after: idx.range.upperBound ) )
	}

	subscript( idx: Index ) -> Base.SubSequence
	{
		self.base[idx.range]
	}
}

extension Collection
{
	func batched( by size: Int ) -> BatchedCollection<Self>
	{
		BatchedCollection( base: self, size: size )
	}
}
