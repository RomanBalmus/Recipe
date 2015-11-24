//
//  TodayRecipe.swift
//  Recipe
//
//  Created by iOS on 24/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
import UIKit

class TodayRecipe: UIView {
    
    @IBOutlet var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
    }
    
   
    
}
