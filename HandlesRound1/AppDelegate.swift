//
//  AppDelegate.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit





struct GraphEditingView {
  let build: (CGSize, [Edge]) -> (GraphPositions, [Edge])
  let size : (ScaffGraph) -> CGSize
  let composite : (ScaffGraph) -> (CGPoint) -> [Geometry]
  let origin : (ScaffGraph, CGRect, CGFloat) -> CGPoint
  let parseEditBoundaries : (ScaffGraph) -> GraphPositions2DSorted
}
func graphViewGenerator(
  build: @escaping (CGSize, [Edge]) -> (GraphPositions, [Edge]),
  size : @escaping (ScaffGraph) -> CGSize,
  composite : [(ScaffGraph) -> (CGPoint) -> [Geometry]],
  origin : @escaping (ScaffGraph, CGRect, CGFloat) -> CGPoint,
  parseEditBoundaries : @escaping (ScaffGraph) -> GraphPositions2DSorted
  )-> [GraphEditingView]
{
  return composite.map {
    GraphEditingView( build: build,
                      size: size,
                      composite: $0,
                      origin: origin,
                      parseEditBoundaries: parseEditBoundaries)
  }
}




func opposite(b: Bool) -> Bool { return !b }




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
      self.window = UIWindow(frame: UIScreen.main.bounds)

      self.window?.makeKeyAndVisible()
      
      let initial = CGSize3(width: 300, depth: 0, elev: 400) |> createGrid
      let graph = ScaffGraph(grid: initial.0, edges: initial.1)
      // graph is passed passed by reference here ...

      
      
      
      let frontMap = graphViewGenerator(
        build: sizeFront(graph) |> overall, //>>> createScaffolding,
        size: sizeFromFullScaff,
        composite: [front1,
                    front1 <> frontDim,
                    front1 <> frontDim <> frontOuterDimPlus,
                    front1 <> frontDim <> frontOuterDimPlus <> frontOverall,
                    { $0.frontEdgesNoZeros } >>> curry(modelToLinework)],
        origin: originFromFullScaff,
        parseEditBoundaries: frontPositionsOhneStandards)
      
//      let frontMap2 = graphViewGenerator(
//        build: overall, //>>> createScaffolding,
//        size: sizeSchematicFront,
//        composite: [front1,
//                    front1 <> frontDim,
//                    front1 <> frontDim <> frontOuterDimPlus,
//                    front1 <> frontDim <> frontOuterDimPlus <> frontOverall,
//                    { $0.frontEdgesNoZeros } >>> curry(modelToLinework)],
//        origin: originFromFullScaff,
//        parseEditBoundaries: frontPositionsOhneStandards)
      
      let uR = SpriteScaffViewController(graph: graph, mapping: frontMap)
      
//      let uR2 = SpriteScaffViewController(graph: graph, mapping: frontMap2)
      self.window?.rootViewController = uR
      
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

