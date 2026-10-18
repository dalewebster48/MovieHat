import Foundation

final class Debouncer {
    private let delay: TimeInterval
    private var task: Task<Void, Never>?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func run(_ block: @escaping () -> Void) {
        task?.cancel()
        task = Task { [delay] in
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            block()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
