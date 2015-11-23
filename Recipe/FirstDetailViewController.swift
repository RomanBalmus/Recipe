//
//  FirstDetailViewController.swift
//  Recipe
//
//  Created by iOS on 23/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
class FirstDetailViewController: UIViewController {
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            let cv = detail.relationForKey("Ingredient_id")
            //print("cv \(cv)")
            cv.query()!.findObjectsInBackgroundWithBlock {
                (robjects:[PFObject]?, error: NSError?) -> Void in
                if let robjects = robjects   {
                    for robject in robjects{
                        print("robject \(robject)")
                    }
                }
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
