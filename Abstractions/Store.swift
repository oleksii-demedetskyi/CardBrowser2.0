final class Store<State> {
    init(state: State, reduce: @escaping (State, Action) -> State) {
        self.state = state
        self.reduce = reduce
    }
    
    private let reduce: (State, Action) -> State
    private var state: State
    
    func dispatch(action: Action) {
        self.state = reduce(state, action)
        observers.forEach { $0.perform(with: self.state) }
    }
    
    var observers: Set<CommandWith<State>> = []
    
    func observe(with command: CommandWith<State>) {
        observers.insert(command)
        command.perform(with: state)
    }
}
