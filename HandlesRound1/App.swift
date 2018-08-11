//
//  App.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Singalong
import Graphe
import Volume




class LoadingViewController : UIViewController {
  
}

public class App {
  public init() {
    Current = .mock
    
  }
  
  public lazy var rootController: UINavigationController = {
    let load = Current.file.load()
    
    switch load {
    case let .success(value):
      
      let edit = EditViewController(
        config: EditViewContConfiguration(
          initialValue: value.contents)
        { (anItem:Item<ScaffGraph> , cell: UITableViewCell) -> UITableViewCell in
          cell.textLabel?.text = anItem.name
          return cell
        }
      )
      edit.didSelect = { (item, cell) in
        self.rootController.pushViewController(self.gridNavigator(id: cell.id).vc, animated: true)
      }
      let nav = UINavigationController(rootViewController: edit)
      styleNav(nav)
      return nav
    case let .error(error):
      fatalError()
    }
  
    
    
    
    
  }()
  
  
  public func gridNavigator(id: String) -> GraphNavigator {
    return GraphNavigator(id: id)
  }
  
  @objc func dismiss3D() {
    self.rootController.dismiss(animated: true, completion: nil)
  }
  
  
  
  
  
}



func styleNav(_ ulN: UINavigationController) {
  ulN.navigationBar.prefersLargeTitles = true
  let nav = ulN.navigationBar
  nav.barStyle = UIBarStyle.blackTranslucent
  nav.tintColor = .white
  nav.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
}

func embedInNav(_ vc: UIViewController)-> UINavigationController {
  let ulN = UINavigationController(rootViewController: vc)
  return ulN
}

func inToOut<A>( _ f: @escaping (A)->Void) -> (A)->A {
  return { a in
    f(a)
    return a
  }
}

public class GraphNavigator {
  init(id: String) {
    self.id = id
  }
  
  var graph : ScaffGraph {
    get {
      return Current.model.getItem(id: id)!.content
    }
  }
  
  lazy var vc: UIViewController = {

    let func1 : (EditingViews.ViewMap)->UIViewController = { ($0, self.graph) } >>> curry(controllerFromMap)(self)
//    >>> embedInNav
//    >>> inToOut(styleNav)
    
    
    let vc = VerticalPageController(
      upperLeft: Current.viewMaps.plan |> func1,
      upperRight: Current.viewMaps.rotatedPlan |> func1,
      lowerLeft: Current.viewMaps.front |> func1,
      lowerRight: Current.viewMaps.side |> func1)
    vc.title = Current.viewMaps.plan.label
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.present3D))
    return vc
  }()
  
  let id : String
  @objc func present3D()
  {
    let scaffProvider = Current.model.getItem(id: id)!.content |> provider
    let newVC = CADViewController(grid: scaffProvider)
    
    let ulN = UINavigationController(rootViewController: newVC)
    ulN.navigationBar.prefersLargeTitles = false
    let nav = ulN.navigationBar
    newVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Dismiss",
      style: UIBarButtonItem.Style.plain ,
      target: self,
      action: #selector(App.dismiss3D)
    )
    
    
    //self.rootController.present(ulN, animated: true, completion: nil)
  }
  
  
}

func controllerFromMap(target: Any, _ vm: EditingViews.ViewMap, graph: ScaffGraph) -> UIViewController
{
  let driver = SpriteDriver(mapping: vm.viewMap, graph: graph)
  let vc : ViewController = ViewController(driver: driver)
  let st = vm.label
  vc.title = st
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: target, action: #selector(GraphNavigator.present3D))
  return vc
}
