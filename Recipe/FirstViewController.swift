//
//  FirstViewController.swift
//  Recipe
//
//  Created by iOS on 20/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import UIKit

class FirstViewController : UIViewController , UITableViewDelegate , UITableViewDataSource {
    var allObjectArray: NSMutableArray = []
    var elements: NSMutableArray = []
    
    @IBOutlet weak var firstTableView: UITableView!
    var currentPage = 0
    var nextpage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.firstTableView.dataSource=self
        self.firstTableView.delegate=self
      
        
        
  
        
            
        
    }
    
    
    func parseData(){
        
        let localquery = PFQuery(className:"Recipes")
        localquery.fromLocalDatastore()
        localquery.orderByAscending("createdAt")
        localquery.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) recipes.")
                if objects?.count > 0 {
                    if let objects = objects   {
                        for object in objects {
                            self.elements.insertObject(object, atIndex: 0)

                            self.firstTableView.reloadData()

                            print("localid : \(object.objectId)")
                            
                            
                        }
                        
                        let localLast = objects.last! as PFObject
                        
                        let remotelast = NSUserDefaults.standardUserDefaults().objectForKey("last_insert") as! NSDate
                        print("localLast: \(localLast.createdAt! as NSDate) and remoteLast: \(remotelast)")
                        
                        
                       // if localLast.createdAt!.isLessThanDate(remotelast) || localLast.createdAt!.isEqualToDateExtension(remotelast){
                            let syncquery = PFQuery(className:"Recipes")
                            syncquery.whereKey("createdAt", greaterThan: remotelast)
                            syncquery.findObjectsInBackgroundWithBlock {
                                (objectss:[PFObject]?, errors: NSError?) -> Void in
                                
                                if let objectss = objectss   {
                                    for objectsy in objectss {
                                        print("syncqueryid : \(objectsy.objectId)")
                                        self.elements.insertObject(objectsy, atIndex: 0)

                                         objectsy.pinInBackground()
                                        NSUserDefaults.standardUserDefaults().setObject(objectsy.createdAt! as NSDate, forKey: "last_insert")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                        self.firstTableView.reloadData()

                                    }
                                }else{
                                    print("Error syncquery: \(errors!) \(errors!.userInfo)")
                                    
                                }
                            }
                       // }
                        
                    }
                    
                }else{
                    let remotequery = PFQuery(className:"Recipes")
                    remotequery.findObjectsInBackgroundWithBlock {
                        (objectsr:[PFObject]?, errorr: NSError?) -> Void in
                        
                        if let objectsr = objectsr   {
                            for objectr in objectsr {
                                print("remoteid : \(objectr)")
                                
                                self.elements.insertObject(objectr, atIndex: 0)

                                 objectr.pinInBackground()
                                NSUserDefaults.standardUserDefaults().setObject(objectr.createdAt, forKey: "last_insert")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                
                                self.firstTableView.reloadData()

                            }
                        }else{
                            print("Error remote: \(errorr!) \(errorr!.userInfo)")
                            
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error local: \(error!) \(error!.userInfo)")
            }
        }
        
        //elements.addObjectsFromArray(allObjectArray.subarrayWithRange(NSMakeRange(0, 20)))



    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    override func viewWillAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            print("we are logged and we are good to go")
            Utilities.askNotifications(UIApplication.sharedApplication())
            if elements.count==0{
            parseData()
            }
            
        }
        else{
            Utilities.loginUser(self)
        }
        
        super.viewWillAppear(animated)
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return elements.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        let recipe = elements.objectAtIndex(indexPath.row) as! PFObject
        cell.textLabel!.text = recipe.objectForKey("name") as? String
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "firstDetail" {
            if let indexPath = self.firstTableView.indexPathForSelectedRow {
                let object = elements[indexPath.row] as! PFObject
                let controller = segue.destinationViewController as! FirstDetailViewController
                controller.detailItem = object
                
            }
        }
    }
    
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
       /* nextpage = elements.count - 5
        if indexPath.row == nextpage {
            currentPage++
            nextpage = elements.count - 5
            elements.addObjectsFromArray(allObjectArray.subarrayWithRange(NSMakeRange(currentPage, 20)))
            tableView.reloadData()
        }*/
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    
    func isEqualToDateExtension(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame
        {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

