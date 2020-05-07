import Foundation

extension Future {

    /// Create a Future whose computation can be retried on failure
    /// - Parameters:
    ///   - context: The queue
    ///   - maxRetries: maximum number of retries
    ///   - delay: the ammout of seconds to wait after retrying
    ///   - cancellationToken: cancellationToken
    ///   - shouldContinue: a closure that received the Error and decides whether retrying should continue or not
    ///   - compute: The computation to be done
    static func retrying(context: Context = .main,
                         maxRetries: Int,
                         delay: TimeInterval = 0.0,
                         cancellationToken: CancellationToken? = nil,
                         shouldContinue: @escaping (Error) -> Bool = { _ in true },
                         compute: @escaping FutureComputation<T>) -> Future {
        var future = Future(error: Errors.deferred)

        var delays = Array(repeating: delay, count: maxRetries + 1)
        delays[0] = 0.0
        var index = 0
        repeat {
            future = future.recover(context: context) { (error) -> Future<T> in
                guard shouldContinue(error) else {
                    return Future(error: error)
                }
                return DelayedOperation(delay: delays[index],
                                        context: context,
                                        cancellationToken: cancellationToken) { () -> Future<T> in
                    Future(in: context, cancellationToken: cancellationToken, compute: compute)
                }.run()
            }

            index += 1
        } while index < maxRetries
        return future
    }
}
