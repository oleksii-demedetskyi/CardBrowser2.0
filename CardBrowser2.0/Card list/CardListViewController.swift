import UIKit

class CardListViewController: UITableViewController {
    private var props: Props = Props(items: [], loader: nil)
    
    func render(props: Props) {
        self.props = props
        
        guard isViewLoaded else { return }
        
        tableView.reloadData()
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        if props.loader != nil {
            return props.items.count + 1
        } else {
            return props.items.count
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { fatalError() }
        
        if indexPath.row == props.items.count {
            cell.isUserInteractionEnabled = false
            switch props.loader?.state {
            case .loading?: cell.textLabel?.text = "Loading..."
            case .failed?: cell.textLabel?.text = "Cannot load next page."
            default: fatalError()
            }
        } else {
            cell.textLabel?.text = props.items[indexPath.row].title
        }
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
        
        guard indexPath.row == props.items.count else {
            return
        }
        
        props.loader?.willDsplay.perform()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "show card details" else { fatalError() }
        guard let cell = sender as? UITableViewCell else { fatalError() }
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError() }
        guard props.items.indices.contains(indexPath.row) else { fatalError() }
        
        props.items[indexPath.row].select.perform(with: segue.destination)
    }
}

