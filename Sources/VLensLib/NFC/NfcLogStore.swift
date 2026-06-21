import Foundation

/// Thread-safe in-memory log store for NFC passport reading.
/// Each entry has: ts, level (D/W/E), tag, message.
final class NfcLogStore {

    static let shared = NfcLogStore()
    private init() {}

    private var entries: [[String: String]] = []
    private let lock = NSLock()

    private let fmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    func add(_ level: String, _ tag: String, _ message: String) {
        let entry = ["ts": fmt.string(from: Date()), "level": level, "tag": tag, "message": message]
        lock.lock(); entries.append(entry); lock.unlock()
        NSLog("[NFC][%@][%@] %@", level, tag, message)
    }

    func snapshot() -> [[String: String]] {
        lock.lock(); defer { lock.unlock() }
        return entries
    }

    func clear() {
        lock.lock(); entries.removeAll(); lock.unlock()
    }
}
