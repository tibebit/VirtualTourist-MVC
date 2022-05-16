//
//  SceneDelegate.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 14/05/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var dataController:DataController!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        loadPersistentStore()
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationVC = navigationController.topViewController as! TravelLocationVC
        travelLocationVC.dataController = dataController
    }

    //MARK: Persistent Store Loading
    func loadPersistentStore() {
        dataController = DataController(modelName: "VirtualTourist")
        dataController.load()
    }
}

