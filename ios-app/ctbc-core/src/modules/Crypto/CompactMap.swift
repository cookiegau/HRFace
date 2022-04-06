#if swift( >=4.1 )
// TODO: remove this file when Xcode 9.2 is no longer used
#else
extension Sequence {
public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
try flatMap(transform)
}
}
#endif
