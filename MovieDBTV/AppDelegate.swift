//
//  AppDelegate.swift
//  MovieDBTV
//
//  Created by Alfian Losari on 23/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let tabBarController = self.window!.rootViewController as! UITabBarController
        let endpoints: [Endpoint] = [.nowPlaying, .upcoming, .popular, .topRated]
        var viewControllers = endpoints.map { (endpoint) -> UIViewController in
            
            let movieVC = tabBarController.storyboard!.instantiateViewController(withIdentifier: "MovieListViewController") as! MovieListViewController
            movieVC.endpoint = endpoint
            movieVC.title = endpoint.description
            return movieVC
        }
        
        viewControllers.append(createSearch(storyboard: tabBarController.storyboard))
        
        tabBarController.viewControllers = viewControllers
        
        
        return true
    }

    
    func createSearch(storyboard: UIStoryboard?) -> UIViewController {
        guard let newsController = storyboard?.instantiateViewController(withIdentifier: "MovieListViewController") as? MovieListViewController else {
            fatalError("Unable to instantiate a NewsController")
        }
        
        let searchController = UISearchController(searchResultsController: newsController)
        searchController.searchResultsUpdater = newsController
        
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = "Search"
        return searchContainer
    }
    

}

