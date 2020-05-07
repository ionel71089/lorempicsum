import Foundation

/// The writable counterpart to Future. The owning object of the Promise *must* `resolve` or `reject` it.
/// This can only be done once. Further calling `resolve` or `reject` will be ignored.
final public class Promise<T> {
    public let future: Future<T>

    /// The writable counterpart to Future. The owning object of the Promise *must* `resolve` or `reject` it.
    /// This can only be done once. Further calling `resolve` or `reject` will be ignored.
    /// - Parameter context: The queue
    public init(in context: Context = .main) {
        future = Future<T>(in: context) { _, _ in }
    }

    /// Resolve the Promise with a result.
    /// - Parameter value: the successful result
    /// - Note: can only be called once.
    public func resolve(value: T) {
        future.send(value: .success(value))
    }

    /// Reject the Promise with an error
    /// - Parameter error: the error
    /// - Note: can only be called once.
    public func reject(error: Error) {
        future.send(value: .failure(error))
    }
}
