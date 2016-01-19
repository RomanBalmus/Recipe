//
//  FifthViewController.swift
//  Recipe
//
//  Created by iOS on 20/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import UIKit
class FifthViewController : UIViewController , APIControllerProtocol{
    lazy var api: Api = Api(delegate: self)
    
    func didReceiveAPIError(error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            print("update UI with error \(error.localizedDescription)")
        }
    }
    func didReceiveAPIResults(results: NSDictionary?) {
        let resultDict = results!
        let someData = resultDict["success"] as! String
        if (someData == "1"){
        }else{
            
        }
        dispatch_async(dispatch_get_main_queue()) {
            print("update UI with new data \(someData)")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        api.getProductList( ["fname": "abc", "lname": "def"]){
            (data, error) -> Void in
            //any additional processing, other REST calls, etc.
                print("prod \(data )")

            
        }
       
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
