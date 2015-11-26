//
//  SecondDetailViewController.swift
//  Recipe
//
//  Created by iOS on 26/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
class SecondSubCatDetailViewController : UIViewController, UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate {
    var detailItem : AnyObject?
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
            let searchController = self.storyboard?.instantiateViewControllerWithIdentifier("CATEGORY_SEARCH_VIEW_CONTROLLER") as? CategorySearchViewController
            searchController?.setSearchTextReady(searchBar.text! as String,obj: self.detailItem as! PFObject)
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
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.firstTableView.addSubview(refreshControl)
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searcBarButtonItemClicked:") //Use a selector
        navigationItem.rightBarButtonItem = searchButton
        parseData()
    }
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        if elements.count > 0{
            elements.removeAllObjects()
            
        }
        self.firstTableView.reloadData()
        parseData()
    }
   
    func parseData(){
        
        let rel = (self.detailItem as! PFObject).relationForKey("sub_categoryId")
        let localquery = rel.query()!
        localquery.orderByAscending("createdAt")
        localquery.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) sub cat.")
                if objects?.count > 0 {
                    if let objects = objects   {
                        for object in objects {
                            print("got \(object.valueForKey("name"))")
                            self.firstTableView.beginUpdates()
                            self.elements.insertObject(object, atIndex: 0)
                            
                            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                            
                            self.firstTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            self.firstTableView.endUpdates()
                        }
                    }
                }else{
                    print("no matches")
                    
                }
                
            }else{
                print("error get search \(error?.userInfo)")
            }
        }
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
    
}