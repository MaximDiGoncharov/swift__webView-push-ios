//
//  appDelegate.swift
//  app.laxo
//
//  Created by Max Goncharov on 23.09.2024.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Создаем окно
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Создаем экземпляр вашего ViewController
        let viewController = ViewController()
        
        // Устанавливаем корневой контроллер
        window?.rootViewController = viewController
        
        // Делаем окно видимым
        window?.makeKeyAndVisible()
        
        return true
    }
}

