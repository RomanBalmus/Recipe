//
//  CheckBox.swift
//  Recipe
//
//  Created by iOS on 30/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "checkedBtn")! as UIImage
    let uncheckedImage = UIImage(named: "uncheckedBtn")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, forState: .Normal)
            } else {
                self.setImage(uncheckedImage, forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        //self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        //self.isChecked = false
    }
    
  
    func check(){
        if isChecked == true {
            isChecked = false
        } else {
            isChecked = true
            
        }
    }
   /* func buttonClicked(sender: UIButton) {
        if sender == self {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true

            }
        }
    }*/
   
}