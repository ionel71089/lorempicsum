import Foundation

public func all<T>(_ futures: Future<T>...) -> Future<[T]> {
    return all(futures)
}

/// Runs a sequence of Futures of the same type. If one fails, the entire operation fails.
/// - Parameter futures: a sequence of futures
/// - Returns: Future<[T]> - a future with an array of successful objects
public func all<T, S: Sequence>(_ futures: S) -> Future<[T]> where S.Iterator.Element == Future<T> {
    let futures = Array(futures)

    if futures.count == 0 {
        return Future(resolved: [])
    }

    return Future<[T]> { completion, _ in
        var elements: [T?] = Array(repeating: nil, count: futures.count)

        func allCompleted() -> Bool {
            return !(elements.contains { $0 == nil })
        }

        let context = Context.custom(queue: DispatchQueue(label: "future.async.all"))

        futures.enumerated().forEach { index, currentFuture in
            currentFuture
                .onSuccess(context) { element in
                    elements[index] = element
                    if allCompleted() {
                        let result = elements.compactMap { $0 }
                        completion(.success(result))
                    }
                }
                .onError(context) { error in
                    completion(.failure(error))
                }
        }
    }
}

/// Runs a sequence of Futures of the same type. All the results are acumulated.
/// - Parameter futures: a sequence of futures
/// - Returns: Future<[T]> - a future with an array of results
public func allCompleted<T, S: Sequence>(_ futures: S) -> Future<[Result<T, Error>]> where S.Iterator.Element == Future<T> {
    let futures = Array(futures)

    if futures.count == 0 {
        return Future(resolved: [])
    }

    return Future<[Result<T, Error>]> { completion, _ in
        var elements: [Result<T, Error>?] = Array(repeating: nil, count: futures.count)

        func allCompleted() -> Bool {
            return !(elements.contains { $0 == nil })
        }

        let context = Context.custom(queue: DispatchQueue(label: "future.async.all.completed"))

        futures.enumerated().forEach { index, currentFuture in
            currentFuture
                .onResult(context) { result in
                    elements[index] = result
                    if allCompleted() {
                        let finalResult = elements.compactMap { $0 }
                        completion(.success(finalResult))
                    }
                }
        }
    }
}

private struct ErasingWrapper {
    var value: Any
}

private func erased<T>(_ future: Future<T>) -> Future<ErasingWrapper> {
    future.map { ErasingWrapper(value: $0) }
}

// swiftlint:disable identifier_name
// swiftlint:disable force_cast

extension Future {
    /// Runs two Futures of different types in parallel. If one fails, the whole operation fails
    /// - Parameters:
    ///   - a: the first future of result type A
    ///   - b: the second future of result type B
    /// - Returns: a Future having the result type a tuple of (A, B)
    public static func parallelize<A, B>(_ a: Future<A>, _ b: Future<B>) -> Future<(A, B)> {
        all([erased(a), erased(b)])
            .map {
                (
                    $0[0].value as! A,
                    $0[1].value as! B
                )
            }
    }
}

// swiftlint:enable identifier_name
// swiftlint:enable force_cast
