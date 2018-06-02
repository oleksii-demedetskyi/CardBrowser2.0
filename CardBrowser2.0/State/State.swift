import Foundation

struct State: Codable {
    let items: [CardLink]
    
    let nextPage: URL?
    let isLoading: Bool
    let isFailed: Bool
}

func reduce(state: State, action: Action) -> State {
    return State(
        items: reduce(items: state.items, action: action),
        nextPage: reduce(nextPage: state.nextPage, action: action),
        isLoading: reduce(isLoading: state.isLoading, action: action),
        isFailed: reduce(isFailed: state.isFailed , action: action)
    )
}

func reduce(items: [CardLink], action: Action) -> [CardLink] {
    guard let action = action as? PageRefreshCompleted else {
        return items
    }
    
    return items + action.response.results
}

func reduce(nextPage: URL?, action: Action) -> URL? {
    guard let action = action as? PageRefreshCompleted else {
        return nextPage
    }
    
    return action.response.next
}

func reduce(isLoading: Bool, action: Action) -> Bool {
    switch action {
    case is PageRefreshStarted: return true
    case is PageRefreshFailed: return false
    case is PageRefreshCompleted: return false
    default: return isLoading
    }
}

func reduce(isFailed: Bool, action: Action) -> Bool {
    switch action {
    case is PageRefreshStarted: return false
    case is PageRefreshFailed: return true
    case is PageRefreshCompleted: return false
    default: return isFailed
    }
}

