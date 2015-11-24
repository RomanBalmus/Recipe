//
//  Helpers.swift
//  Recipe
//
//  Created by iOS on 24/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
func generateRandomData() -> [[UIColor]] {
    let numberOfRows = 1
    let numberOfItemsPerRow = 15
    
    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

extension UIColor {
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}