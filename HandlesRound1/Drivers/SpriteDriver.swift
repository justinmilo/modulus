//
//  SpriteDriver.swift
//  HandlesRound1
//
//  Created by Justin Smith on 6/16/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Singalong
import Layout





struct SpriteDriver  : Driver {
  
  
  public init(mapping: [GraphEditingView] )
  {
    editingView = mapping[0]
    loadedViews = mapping
    initialFrame = Current.screen
    
    twoDView = Sprite2DView(frame:initialFrame )
    twoDView.layer.borderWidth = 1.0
    twoDView.scene?.scaleMode = .resizeFill
  }
  
  func layout(origin: CGPoint) {
    self.twoDView.mainNode.position = uiPointToSprite(origin)
  }
  
  var _previousRect = CGRect.zero
  /// Handler for Selection Size Changed
  ///
  /// Checks if newSize should be redrawn
  mutating func layout(size: CGSize) {
        // Create New Model &  // Find Orirgin
    // Setting up our interior vie
    let newRect = CGRect(origin: self.twoDView.mainNode.position, size: size)
    
    if newRect.size != _previousRect.size {
      // Set & Redraw Geometry
      let a = Current.graph |> self.editingView.composite
      self.twoDView.redraw(a)
      self.twoDView.draw(newRect)
    }
    self._previousRect = newRect
  }
  
  func size(for size: CGSize) -> CGSize {
    let s3 = size |> self.editingView.size3(Current.graph)
    (Current.graph.grid, Current.graph.edges) = self.editingView.build(s3, Current.graph.edges)
    return Current.graph |> self.editingView.size
  }
  
  // Drawing pure function
  var editingView : GraphEditingView
  var loadedViews : [GraphEditingView]
  
  var twoDView : Sprite2DView
  
  var content : UIView { return self.twoDView }
  
  // Eventually dependency injected
  var initialFrame : CGRect
  
  
  
  mutating func bind(to uiRect: CGRect)
  {
    self.uiPointToSprite = translateToCGPointInSKCoordinates(from: uiRect, to: twoDView.frame)
  }
  
  var uiPointToSprite : ((CGPoint)->CGPoint)!
}



