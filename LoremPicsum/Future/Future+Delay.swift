import Foundation

public extension Future {

    /// Creates a delayed Future<Void> to be chained to another Future
    /// - Parameters:
    ///   - context: the queue
    ///   - time: the ammount of seconds to delay
    ///   - cancelationToken: cancelationToken
    static func delayed(context: Context = .main,
                        time: TimeInterval,
                        cancelationToken: CancellationToken? = nil) -> Future<Void> {
        let promise = Promise<Void>()

        context.queue.asyncAfter(deadline: .now() + time) {
            promise.resolve(value: ())
        }

        cancelationToken?.onCanceled {
            promise.reject(error: Errors.canceled)
        }

        return promise.future
    }
}

public final class DelayedOperation<T> {
    private let getOperation: () -> Future<T>
    private let cancellationToken: CancellationToken
    private let future: Future<Void>

    public init(delay: TimeInterval,
                context: Context = .main,
                cancellationToken: CancellationToken? = nil,
                getOperation: @escaping () -> Future<T>) {
        self.getOperation = getOperation
        self.cancellationToken = cancellationToken ?? CancellationToken(in: context)
        future = Future<Void>.delayed(context: context, time: delay, cancelationToken: self.cancellationToken)
    }

    public func cancel() {
        cancellationToken.cancel()
    }

    @discardableResult
    public func run() -> Future<T> {
        return future
            .flatMap { _ in
                self.getOperation()
            }
    }
}
