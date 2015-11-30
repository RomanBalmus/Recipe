//
//  FourthViewController.swift
//  Recipe
//
//  Created by iOS on 20/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import UIKit
class FourthViewController : UIViewController , UITableViewDelegate , UITableViewDataSource{
    var elements: NSMutableArray = []
    @IBOutlet weak var firstTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.firstTableView.dataSource=self
        self.firstTableView.delegate=self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
            parseData()
        
    }
    func parseData(){
        if elements.count>0{
            elements.removeAllObjects()
            self.firstTableView.reloadData()
            print("remove")
        }
        
        let user = PFUser.currentUser()!
        let rel = user.relationForKey("toDoList")
        let cv = rel.query()
        cv.fromLocalDatastore()
        cv.orderByAscending("createdAt")
        cv.includeKey("recipeId")
        cv.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            
          //  print("objs: \(objects) error: \(error)")
            if let objects = objects   {
                for object in objects {
                    object.pinInBackground()
                    print("obj \(object)")

                    
                    self.elements.addObject(object["recipeId"] as! PFObject)


                    
                }
                self.firstTableView.reloadData()

            }
            
        }

    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if elements.count>0{
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
     
        return elements.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if  indexPath.section == 0 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("allIngCell", forIndexPath: indexPath) as UITableViewCell
            
            
            return cell
        }else{
        let cell = tableView.dequeueReusableCellWithIdentifier("toDoRecCell", forIndexPath: indexPath) as! ToDoRecCell
        let recipe = elements.objectAtIndex(indexPath.row) as! PFObject
            
            
            
        cell.titleLbl!.text = recipe.objectForKey("name") as? String
        
        
        /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:1]]; // For GMT+1
        NSString *time = [formatter stringFromDate:[NSDate date]];*/
        return cell
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToMultiIngrList" {
                let controller = segue.destinationViewController as! ToDoViewController
                controller.parseMulti(self.elements)
                
                
            
        }
        if segue.identifier == "goToSingleIngrList" {
            if let indexPath = self.firstTableView.indexPathForSelectedRow {
                let object = elements[indexPath.row] as! PFObject
                let controller = segue.destinationViewController as! ToDoViewController
                
                controller.parseSingle(object)
                
              
                
                
            }
        }
    }
    
}
