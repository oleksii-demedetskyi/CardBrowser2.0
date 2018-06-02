//
//  AppDelegate.swift
//  CardBrowser2.0
//
//  Created by Alexey Demedetskii on 5/26/18.
//  Copyright © 2018 Alexey Demedeckiy. All rights reserved.
//

import UIKit

import Moscapsule

final class MQTT {
    
    private var client: MQTTClient!
    
    init() {
        let config = MQTTConfig(
            clientId: "CardBrowser App",
            host: "localhost",
            port: 1883,
            keepAlive: 60)
        
        config.onMessageCallback = { message in
            guard let data = message.payload else { return }
            guard let commands = self.subscriptions[message.topic] else { return }
            
            commands.forEach { $0.perform(with: data) }
        }
        
        client = Moscapsule.MQTT.newConnection(config)
    }
    
    func publishCommand<T>(in topic: String) -> CommandWith<T>
        where T: Codable {
        return CommandWith { value in
            guard let data = try? JSONEncoder().encode(value) else {
                return
            }
            
            self.client.publish(data, topic: topic, qos: 0, retain: true)
        }
    }
    
    private var subscriptions: [String: [CommandWith<Data>]] = [:]
    
    func subscribe<T>(command: CommandWith<T>, to topic: String)
        where T: Decodable {
            let dataCommand = CommandWith<Data> { data in
                guard let value = try? JSONDecoder().decode(T.self, from: data) else {
                    return
                }
                
                command.perform(with: value)
            }
            
            if subscriptions.keys.contains(topic) {
                subscriptions[topic]!.append(dataCommand)
            } else {
                subscriptions[topic] = [dataCommand]
                self.client.subscribe(topic, qos: 0)
            }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let initialState = State(
            items: [],
            nextPage: URL(string: "https://api.gwentapi.com/v0/cards")!,
            isLoading: false,
            isFailed: false
        )
    
        let store = Store(state: initialState, reduce: reduce)
        let mqtt = MQTT()
        
        
        let dispatchAction = CommandWith(action: store.dispatch)
        
        let publishSomeAction: CommandWith<SomeAction> =
            mqtt.publishCommand(in: "/store/action")
        
        let publishAction = publishSomeAction.map { (action: Action) in
            return SomeAction.init(action: action)
        }
        
        let dispatch = publishAction.then(dispatchAction)
        
        let receiveSomeAction = dispatch.map { (some: SomeAction) in
            return some.action
        }
        
        mqtt.subscribe(command: receiveSomeAction, to: "/store/dispatch")
        
        let loadNextPage = LoadNextPage(
            dispatch:dispatch,
            getURL: FakeAPI.getCards)
        
        guard let nvc = window?.rootViewController as? UINavigationController else { fatalError() }
        
        guard let vc = nvc.topViewController as? CardListViewController else { fatalError() }
        
        
        let presentDetailsCommand = CommandWith { args in
            let cardDetailsPresenter = CardDetailsPresenter(
                render: CommandWith(action: args.vc.render),
                item: args.item)
            
            store.observe(with:
                CommandWith(action: cardDetailsPresenter.present))
        } as CommandWith<(vc: CardDetailsViewController, item: CardLink)>
        
        let renderCommand = CommandWith(action: vc.render).dispatched(on: .main)
        
        let publishCommand: CommandWith<CardListViewController.Props> =
            mqtt.publishCommand(in: "/CardList/props")
        
        let render = publishCommand.then(renderCommand)
        
        mqtt.subscribe(command: render, to: "/CardList/render")
        
        let cardListPresenter = CardListPresenter(
            render: render,
            loadNextPage: CommandWith(action: loadNextPage.perform),
            presentDetails: presentDetailsCommand
        )
        
        store.observe(with: CommandWith(action: cardListPresenter.present))
        
        
        
        store.observe(with: mqtt.publishCommand(in: "/store/state"))
        
        
        return true
    }
}

