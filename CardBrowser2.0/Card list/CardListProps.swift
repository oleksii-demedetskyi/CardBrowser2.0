import UIKit

extension CardListViewController {
    struct Props: Codable {
        let items: [Item]; struct Item: Codable {
            let title: String
            let select: CommandWith<UIViewController>
        }
        
        let loader: Loader?; struct Loader: Codable {
            let willDsplay: Command
            let state: State; enum State {
                case loading
                case failed(refresh: Command)
            }
        }
    }
}
