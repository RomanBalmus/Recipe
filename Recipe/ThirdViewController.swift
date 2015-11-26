//
//  ThirdViewController.swift
//  Recipe
//
//  Created by iOS on 20/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import UIKit
class ThirdViewController : UIViewController , UITableViewDelegate , UITableViewDataSource{
    var elements: NSMutableArray = []
    @IBOutlet weak var firstTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.firstTableView.dataSource=self
        self.firstTableView.delegate=self
        self.firstTableView.estimatedRowHeight=100
        self.firstTableView.rowHeight=UITableViewAutomaticDimension
        
        
        
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    func getData(){
        if elements.count>0{
            
            self.firstTableView.reloadData()
            return
        }
        let user = PFUser.currentUser()!
        let rel = user.relationForKey("Favorites")
        let cv = rel.query()!
        cv.orderByAscending("createdAt")
        cv.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            print("objs \(objects)")
            
            if let objects = objects   {
                for object in objects {
                    print("obj \(object)")
                    
                    self.firstTableView.beginUpdates()
                    self.elements.insertObject(object, atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    
                    self.firstTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    self.firstTableView.endUpdates()
                    
                    print("elem \(self.elements)")
                    
                }
            }
            
        }
 
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return elements.count
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.firstTableView.beginUpdates()
            let obj = elements.objectAtIndex(indexPath.row) as! PFObject
            let usr = PFUser.currentUser()!
            let rel = usr.relationForKey("Favorites")
            rel.removeObject(obj)
            usr.saveInBackground()
            elements.removeObject(obj)
            tableView.deleteRowsAtIndexPaths([indexPath],  withRowAnimation: UITableViewRowAnimation.Automatic)
            self.firstTableView.endUpdates()

        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as! SearchCell
        let recipe = elements.objectAtIndex(indexPath.row) as! PFObject
        cell.title.text = recipe.objectForKey("name") as? String
        
        
        /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:1]]; // For GMT+1
        NSString *time = [formatter stringFromDate:[NSDate date]];*/
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let object = elements[indexPath.row] as! PFObject
        let detail = self.storyboard?.instantiateViewControllerWithIdentifier("FIRST_DETAIL_VIEW_CONTROLLER") as? FirstDetailViewController
        // detail?.setSearchTextReady(searchBar.text! as String)
        detail!.detailItem = object
        
        self.navigationController?.pushViewController(detail!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
}
