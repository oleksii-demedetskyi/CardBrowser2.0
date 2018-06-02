struct CardDetailsPresenter {
    typealias Props = CardDetailsViewController.Props
    
    let render: CommandWith<Props>
    let item: CardLink
    
    func present(state: State) {
        render.perform(with:
            Props(title: item.name)
        )
    }
}
