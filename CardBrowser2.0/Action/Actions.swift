protocol Action: Codable {}

struct PageRefreshStarted: Action {}

struct PageRefreshFailed: Action {}

struct PageRefreshCompleted: Action {
    let response: CardsResponse
}

enum SomeAction {
    case pageRefreshStarted(PageRefreshStarted)
    case pageRefreshFailed(PageRefreshFailed)
    case pageRefrshCompleted(PageRefreshCompleted)
    
    init<T>(action: T) {
        switch action {
        case let action as PageRefreshStarted:
            self = .pageRefreshStarted(action)
        case let action as PageRefreshFailed:
            self = .pageRefreshFailed(action)
        case let action as PageRefreshCompleted:
            self = .pageRefrshCompleted(action)
        default: fatalError("Unknown action: \(action)")
        }
    }
    
    var action: Action {
        switch self {
        case .pageRefreshFailed(let action): return action
        case .pageRefreshStarted(let action): return action
        case .pageRefrshCompleted(let action): return action
        }
    }
}

extension SomeAction: Codable {
    enum Keys: CodingKey { case type, value }
    enum Cases: String, Codable {
        case pageRefreshStarted
        case pageRefreshFailed
        case pageRefreshCompleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        switch try container.decode(Cases.self, forKey: .type) {
        case .pageRefreshFailed:
            self = .pageRefreshFailed(
                try container.decode(PageRefreshFailed.self, forKey: .value))
        case .pageRefreshStarted:
            self = .pageRefreshStarted(
                try container.decode(PageRefreshStarted.self, forKey: .value))
        case .pageRefreshCompleted:
            self = .pageRefrshCompleted(
                try container.decode(PageRefreshCompleted.self, forKey: .value))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        switch self {
        case .pageRefreshStarted(let action):
            try container.encode(Cases.pageRefreshStarted, forKey: .type)
            try container.encode(action, forKey: .value)
        case .pageRefreshFailed(let action):
            try container.encode(Cases.pageRefreshFailed, forKey: .type)
            try container.encode(action, forKey: .value)
        case .pageRefrshCompleted(let action):
            try container.encode(Cases.pageRefreshCompleted, forKey: .type)
            try container.encode(action, forKey: .value)
        }
    }
}

