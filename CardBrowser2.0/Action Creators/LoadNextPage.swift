import Foundation

struct LoadNextPage {
    let dispatch: CommandWith<Action>
    let getURL: (URL) -> Future<CardsResponse?>
    
    func perform(with page: URL) {
        dispatch.perform(with: PageRefreshStarted())
        
        getURL(page).onComplete { response in
            guard let response = response else {
                return self.dispatch.perform(with:
                    PageRefreshFailed())
            }
            
            self.dispatch.perform(with:
                PageRefreshCompleted(response: response))
        }
    }
}
