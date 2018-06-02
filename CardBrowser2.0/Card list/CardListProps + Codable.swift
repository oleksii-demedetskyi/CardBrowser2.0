extension CardListViewController.Props.Loader.State: Codable {
    enum Keys: CodingKey {
        case type, value
    }
    
    enum Case: String, Codable {
        case loading, failed
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        switch self {
        case .loading:
            try container.encode(Case.loading, forKey: .type)
            
        case .failed(refresh: let refresh):
            try container.encode(Case.failed, forKey: .type)
            try container.encode(refresh, forKey: .value)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try container.decode(Case.self, forKey: .type)
        
        switch type {
        case .loading: self = .loading
        case .failed: self = .failed(refresh:
            try container.decode(
                Command.self, forKey: .value))
        }
    }
}

