import Foundation

struct CardListPresenter {
    typealias Props = CardListViewController.Props
    
    let render: CommandWith<Props>
    let loadNextPage: CommandWith<URL>
    let presentDetails: CommandWith<(vc: CardDetailsViewController, item: CardLink)>
    
    func present(state: State) {
        func loader() -> Props.Loader? {
            
            func loadNextPage() -> Command {
                if state.isLoading {
                    return .nop
                }
                guard let url = state.nextPage else {
                    return .nop
                }
                
                return self.loadNextPage.bind(to: url)
            }
            
            guard state.nextPage != nil else {
                return nil
            }
            
            if state.isFailed {
                return Props.Loader(
                    willDsplay: loadNextPage(),
                    state: .failed(refresh: loadNextPage()))
            }
            else {
                return Props.Loader(
                    willDsplay: loadNextPage(),
                    state: .loading)
            }
        }

        render.perform(with: Props(
            items: state.items.map { item in
                Props.Item(
                    title: item.name,
                    select: presentDetails.map { vc in
                        guard let detailsVC = vc as? CardDetailsViewController else {
                            fatalError()
                        }
                        return (detailsVC, item)
                    }
                )
            },
            loader: loader()))
    }
}
