//
//  SecondViewController.swift
//  Recipe
//
//  Created by iOS on 20/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import UIKit

class SecondViewController : UIViewController , UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate{
    var resultSearchController : UISearchController!
    var elements: NSMutableArray = []
    var refreshControl:UIRefreshControl!
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    var searchActive : Bool = false
    @IBAction func searcBarButtonItemClicked(sender: AnyObject) {
        
        if searchActive{
            hideSearchBar()
            
        }else{
            showSearchBar()
        }
        
    }
    
    func showSearchBar() {
        
        
        presentViewController(resultSearchController, animated: true, completion: nil)
        self.searchActive = true
        
    }
    
    func hideSearchBar() {
        
        self.resultSearchController.dismissViewControllerAnimated(true, completion: nil)
        
        UIView.animateWithDuration(0.3, animations: {
            
            }, completion: { finished in
                self.searchActive = false
        })
    }
    
    
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        print("cancel")
        hideSearchBar()
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("done clicked \(searchBar.text)")
        //hideSearchBar()
        self.resultSearchController.dismissViewControllerAnimated(true, completion: {
            self.searchActive=false
            
            let searchController = self.storyboard?.instantiateViewControllerWithIdentifier("SEARCH_VIEW_CONTROLLER") as? SearchViewController
            searchController?.setSearchTextReady(searchBar.text! as String)
            self.navigationController?.pushViewController(searchController!, animated: true)
        })
        
        
        
    }
    deinit{
        if let superView = resultSearchController.view.superview
        {
            superView.removeFromSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.delegate = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.firstTableView.dataSource=self
        self.firstTableView.delegate=self
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.firstTableView.addSubview(refreshControl)
        
        
        if elements.count==0{
            parseData()
        }
    }
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        if elements.count > 0{
            elements.removeAllObjects()
            self.firstTableView.reloadData()

        }
        parseData()
    }
    func parseData(){
      
        let localquery = PFQuery(className:"Category")
        localquery.fromLocalDatastore()
        localquery.orderByDescending("name")
        localquery.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                if objects?.count > 0 {
                    if let objects = objects   {
                        for object in objects {
                            self.firstTableView.beginUpdates()
                            self.elements.insertObject(object, atIndex: 0)
                            
                            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                            
                            self.firstTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            self.firstTableView.endUpdates()
                            object.pinInBackground()
                            
                            
                            
                        }
                        
                        let localLast = objects.last! as PFObject
                        
                        let remotelast = NSUserDefaults.standardUserDefaults().objectForKey("last_insert_cat") as! NSDate
                        print("localLast: \(localLast.createdAt! as NSDate) and remoteLast: \(remotelast)")
                        
                        
                        // if localLast.createdAt!.isLessThanDate(remotelast) || localLast.createdAt!.isEqualToDateExtension(remotelast){
                        let syncquery = PFQuery(className:"Category")
                        syncquery.whereKey("createdAt", greaterThan: remotelast)
                        syncquery.orderByDescending("name")
                        syncquery.findObjectsInBackgroundWithBlock {
                            (objectss:[PFObject]?, errors: NSError?) -> Void in
                            
                            if let objectss = objectss   {
                                for objectsy in objectss {
                                    self.firstTableView.beginUpdates()
                                    self.elements.insertObject(objectsy, atIndex: 0)
                                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                                    
                                    self.firstTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                                    self.firstTableView.endUpdates()
                                    objectsy.pinInBackground()
                                    NSUserDefaults.standardUserDefaults().setObject(objectsy.createdAt! as NSDate, forKey: "last_insert_cat")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    
                                    
                                }
                            }else{
                                print("Error syncquery: \(errors!) \(errors!.userInfo)")
                                
                            }
                        }
                        // }
                        
                    }
                    
                }else{
                    let remotequery = PFQuery(className:"Category")
                    remotequery.orderByDescending("name")
                    remotequery.findObjectsInBackgroundWithBlock {
                        (objectsr:[PFObject]?, errorr: NSError?) -> Void in
                        
                        if let objectsr = objectsr   {
                            for objectr in objectsr {
                                self.firstTableView.beginUpdates()
                                self.elements.insertObject(objectr, atIndex: 0)
                                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                                
                                self.firstTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                                self.firstTableView.endUpdates()
                                objectr.pinInBackground()
                                NSUserDefaults.standardUserDefaults().setObject(objectr.createdAt, forKey: "last_insert_cat")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                
                                
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
        
        if self.refreshControl.refreshing{
            self.refreshControl.endRefreshing()
            
        }
        
    }

  
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
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
        
        
        /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:1]]; // For GMT+1
        NSString *time = [formatter stringFromDate:[NSDate date]];*/
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToSub" {
            if let indexPath = self.firstTableView.indexPathForSelectedRow {
                let object = elements[indexPath.row] as! PFObject
                let controller = segue.destinationViewController as! SecondSubCatDetailViewController
                
                if controller.detailItem != nil{
                    controller.detailItem = nil
                }
                controller.detailItem = object
                print("this obje \(object.objectId)")
                
                
            }
        }

    }

}

