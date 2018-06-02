import Foundation

struct Networking {
    let session: URLSession
    
    func getURL<T: Decodable>(url: URL) -> Future<T> {
        return Future { complete in
            let task = session.dataTask(with: url) { data, response, error in
                let value = try! JSONDecoder().decode(T.self, from: data!)
                complete(value)
            }
            
            task.resume()
        }
    }
}

