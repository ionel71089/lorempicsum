import Foundation

enum Observer<T> {
    typealias ResultHandler = (Result<T, Error>) -> Void
    typealias SuccessHandler = (T) -> Void
    typealias ErrorHandler = (Error) -> Void

    case onResult(Context, ResultHandler)
    case onSuccess(Context, SuccessHandler)
    case onError(Context, ErrorHandler)

    func call(_ result: Result<T, Error>) {
        switch (self, result) {
        case (.onResult(let context, let handler), _):
            context.queue.async {
                handler(result)
            }

        case (.onSuccess(let context, let handler), .success(let value)):
            context.queue.async {
                handler(value)
            }

        case (.onError(let context, let handler), .failure(let error)):
            context.queue.async {
                handler(error)
            }

        default:
            return
        }
    }
}
