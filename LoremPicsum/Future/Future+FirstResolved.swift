import Foundation

/// Runs a sequence of Futures of the same type. The first one to resolve sets the final result. If all futures fail, the final result is an error.
/// - Parameter futures: a sequence of futures
/// - Returns: Future<T> - a future with a single result object
public func firstResolved<T, S: Sequence>(_ futures: S) -> Future<T> where S.Iterator.Element == Future<T> {
    let futures = Array(futures)

    if futures.count == 0 {
        return Future(error: "No futures")
    }

    var countdown = futures.count
    return Future<T> { completion, _ in
        let context = Context.custom(queue: DispatchQueue(label: "future.async.firstResolved"))

        futures.forEach { currentFuture in
            currentFuture
                .onSuccess(context) { element in
                    completion(.success(element))
                }
                .onError(context) { _ in
                    countdown -= 1
                    if countdown <= 0 {
                        completion(.failure("all failed"))
                    }
                }
        }
    }
}
