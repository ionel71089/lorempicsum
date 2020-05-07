import Foundation

public typealias FutureComputation<T> = (@escaping (Result<T, Error>) -> Void, _ cancelation: CancellationToken?) -> Void

/// Represents an async operation that will yield either a T in case of success or an Error in case of failure.
/// Once the operation is finished, the resulting value is guaranteed not to change.
/// - Note: the value is read-only
final public class Future<T> {
    let queue = DispatchQueue(label: "future.async")

    private var cached: Result<T, Error>?
    private var observers: [Observer<T>] = []

    weak var cancellationToken: CancellationToken? {
        didSet {
            cancellationToken?.onCanceled {
                self.send(value: .failure(Errors.canceled))
            }
        }
    }

    /// Represents an async operation that will yield either a T in case of success or an Error in case of failure.
    /// Once the operation is finished, the resulting value is guaranteed not to change.
    /// - Parameters:
    ///   - context: The queue the computation should run on
    ///   - cancellationToken: A token that allows calling `cancel()` on it. The future and all dependant will return `Errors.cancelled`
    ///   - compute: The computation needed to resolve the future's value
    /// - Note: the value of the Future is read-only
    public init(in context: Context = .main,
                cancellationToken: CancellationToken? = nil,
                compute: @escaping FutureComputation<T>) {
        self.cancellationToken = cancellationToken
        cancellationToken?.onCanceled {
            self.send(value: .failure(Errors.canceled))
        }

        context.queue.async {
            compute(self.send, self.cancellationToken)
        }
    }

    /// Create a future with the result already known. No computation is done
    /// - Parameter result: the result of the future
    public init(result: Result<T, Error>) {
        cached = result
    }

    /// Create a future with the result already known and is succesful. No computation is done
    /// - Parameter result: a T
    public init(resolved result: T) {
        cached = .success(result)
    }

    /// Create a future with the result already known and is failed. No computation is done
    /// - Parameter error: an Error
    public init(error: Error) {
        cached = .failure(error)
    }

    /// Set the result of the future. The value can only be set once
    /// - Parameter value: the result of the future
    /// - Warning: This will be internal once moved to library. Should not be called by another class except `Future` and `Promise`
    func send(value: Result<T, Error>) {
        queue.sync {
            if cached == nil {
                cached = value
            }
            for observer in observers {
                observer.call(cached!)
            }
            observers.removeAll()
        }
    }

    /// Add an `Observer` to the future's list of observer. It will be notified exactly once when the computation is finished
    /// or immediately if it has already finished.
    /// - Parameter observer: the observer that will be notified
    /// - Returns: `self`
    private func add(observer: Observer<T>) -> Future<T> {
        queue.sync {
            if let result = cached {
                observer.call(result)
            } else {
                observers.append(observer)
            }
            return self
        }
    }

    /// Register to receive a notification exactly once when the future is resolved or immediately if it has already finished.
    /// - Parameters:
    ///   - context: on what queue the handler will be called. Defaults to main
    ///   - callback: a callback receiving a Result
    /// - Returns: `self`
    @discardableResult public func onResult(_ context: Context? = nil,
                                            callback: @escaping (Result<T, Error>) -> Void) -> Future<T> {
        return add(observer: .onResult(context ?? .main, callback))
    }

    /// Register to receive a notification exactly once when the future is resolved *successfully* or immediately if it has already finished.
    /// - Parameters:
    ///   - context: on what queue the handler will be called. Defaults to main
    ///   - callback: a callback receiving a T
    /// - Returns: `self`
    @discardableResult public func onSuccess(_ context: Context? = nil,
                                             callback: @escaping (T) -> Void) -> Future<T> {
        return add(observer: .onSuccess(context ?? .main, callback))
    }

    /// Register to receive a notification exactly once when the future *fails* or immediately if it has already finished.
    /// - Parameters:
    ///   - context: on what queue the handler will be called. Defaults to main
    ///   - callback: a callback receiving an Error
    /// - Returns: `self`
    @discardableResult public func onError(_ context: Context? = nil,
                                           callback: @escaping (Error) -> Void) -> Future<T> {
        return add(observer: .onError(context ?? .main, callback))
    }

    /// When the future ends in failure, it can recover with another Future
    /// - Parameters:
    ///   - context: The queue the computation should run on
    ///   - transform: A function that takes an error and returns a new Future
    /// - Returns: a new Future
    public func recover(context: Context = .main, _ transform: @escaping (Error) -> Future<T>) -> Future<T> {
        Future<T>(in: context, cancellationToken: cancellationToken) { completion, cancellationToken in
            self.onResult(context) { result in
                switch result {
                case let .success(value):
                    completion(.success(value))
                case let .failure(error):
                    let future = transform(error)
                    future.cancellationToken = cancellationToken
                    future.onResult(callback: completion)
                }
            }
        }
    }

    /// When the future ends in failure, it will resolve to a default value
    /// - Parameters:
    ///   - context: The queue the computation should run on
    ///   - defaultValue: The default value to return in case of failure
    /// - Returns: a new Future
    public func recoverDefault(context: Context = .main, _ defaultValue: T) -> Future<T> {
        Future<T>(in: context, cancellationToken: cancellationToken) { completion, cancellationToken in
            self.onResult(context) { result in
                switch result {
                case let .success(value):
                    completion(.success(value))
                case .failure(_):
                    completion(.success(defaultValue))
                }
            }
        }
    }

    /// Transform the result of a future on success.
    /// - Parameter transform: a function (T) -> U that synchronously transforms an object. (can't fail)
    /// - Returns: a new Future
    public func map<U>(_ transform: @escaping (T) -> U) -> Future<U> {
        // TODO: should we pass the context in ?
        return Future<U>(cancellationToken: cancellationToken) { completion, _ in
            self.onResult { result in
                completion(result.map(transform))
            }
        }
    }

    /// Starts a new async computation that takes as input the result of the current future.
    /// - Parameter transform: a function (T) -> Future<U>
    /// - Returns: a new Future
    public func flatMap<U>(_ transform: @escaping (T) -> Future<U>) -> Future<U> {
        // TODO: should we pass the context in ?
        return Future<U>(cancellationToken: cancellationToken) { completion, cancellationToken in
            self.onResult { result in
                switch result {
                case let .success(value):
                    let future = transform(value)
                    future.cancellationToken = cancellationToken // TODO: Should we check if it has one already ?
                    future.onResult(callback: completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    public func then<U>(_ transform: @escaping (Result<T, Error>) -> Future<U>) -> Future<U> {
        return Future<U>(cancellationToken: cancellationToken) { completion, cancellationToken in
            self.onResult { result in
                let future = transform(result)
                future.cancellationToken = cancellationToken // TODO: Should we check if it has one already?
                future.onResult(callback: completion)
            }
        }
    }
}
