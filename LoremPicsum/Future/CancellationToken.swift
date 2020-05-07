import Foundation

public enum Errors: Error {
    case canceled
    case deferred
}

public extension Error {
    var wasCancelled: Bool {
        if let error = self as? Errors {
            switch error {
            case .canceled:
                return true
            default:
                return false
            }
        }

        return false
    }
}

final public class CancellationToken {
    let promise: Promise<Void>
    let context: Context

    private var _wasCanceled: Bool = false
    public var wasCanceled: Bool {
        return _wasCanceled
    }

    public init(in context: Context = .main) {
        self.context = context
        promise = Promise(in: context)
    }

    public func onCanceled(callback: @escaping () -> Void) {
        promise.future.onError(context) { _ in
            callback()
        }
    }

    public func cancel() {
        _wasCanceled = true // TODO: does this need to be synced ?
        promise.reject(error: Errors.canceled)
    }
}
