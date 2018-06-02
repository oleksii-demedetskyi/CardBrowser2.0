import Foundation

final class Command {
    init(id: String = "unnamed",
         file: StaticString = #file,
         function: StaticString = #function,
         line: Int = #line,
         action: @escaping () -> ())
    {
        self.id = id
        self.action = action
        self.function = function
        self.file = file
        self.line = line
    }
    
    private let file: StaticString
    private let function: StaticString
    private let line: Int
    private let id: String
    
    private let action: () -> ()
    
    func perform() {
        action()
    }
    
    static let nop = Command { }
    
    /// Support for Xcode quick look feature.
    @objc
    func debugQuickLookObject() -> AnyObject? {
        return """
            type: \(String(describing: type(of: self)))
            id: \(id)
            file: \(file)
            function: \(function)
            line: \(line)
            """ as NSString
    }
}

extension Command: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init { }
    }
    
    func encode(to encoder: Encoder) throws {}
}

final class CommandWith<T> {
    init(action: @escaping (T) -> ()) {
        self.action = action
    }
    
    let action: (T) -> ()
    
    func perform(with value: T) {
        action(value)
    }
    
    func bind(to value: T) -> Command {
        return Command { self.perform(with: value) }
    }
    
    static var nop: CommandWith {
        return CommandWith { _ in }
    }
    
    func dispatched(on queue: DispatchQueue) -> CommandWith {
        return CommandWith { value in
            queue.async {
                self.perform(with: value)
            }
        }
    }
    
    func then(_ another: CommandWith) -> CommandWith {
        return CommandWith { value in
            self.perform(with: value)
            another.perform(with: value)
        }
    }
}

extension CommandWith: Hashable {
    static func ==(lhs: CommandWith<T>, rhs: CommandWith<T>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

extension CommandWith: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init { _ in }
    }
    
    func encode(to encoder: Encoder) throws {}
}

extension CommandWith {
    func map<U>(transform: @escaping (U) -> T) -> CommandWith<U> {
        return CommandWith<U> { u in
            self.perform(with: transform(u))
        }
    }
}
