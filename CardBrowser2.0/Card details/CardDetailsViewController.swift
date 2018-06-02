import UIKit

class CardDetailsViewController: UIViewController {
    struct Props {
        let title: String
    }
    
    func render(props: Props) {
        self.title = props.title
    }
}
