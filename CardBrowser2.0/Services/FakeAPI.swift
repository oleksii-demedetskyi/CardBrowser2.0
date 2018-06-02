import Foundation

enum FakeAPI {
    static func getCards(url: URL) -> Future<CardsResponse?> {
        let someURL = URL(string: "google.com")!
        return Future(value: CardsResponse(
            next: someURL,
            results: [
                CardLink(href: someURL, name: "Card 1"),
                CardLink(href: someURL, name: "Card 2"),
                CardLink(href: someURL, name: "Card 3"),
                CardLink(href: someURL, name: "Card 4"),
                CardLink(href: someURL, name: "Card 5"),
                CardLink(href: someURL, name: "Card 6"),
                CardLink(href: someURL, name: "Card 7"),
                CardLink(href: someURL, name: "Card 8")
            ])
            ).deleyed(by: 4.0)
    }
}
