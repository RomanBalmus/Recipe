//
//  SearchViewController.swift
//  Recipe
//
//  Created by iOS on 24/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
class SearchViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate {
    var resultSearchController : UISearchController!
    var elements: NSMutableArray = []
    
    var searchText : String!
    
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
    
    func setSearchTextReady(searchTxt:String){
        self.searchText=searchTxt
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
        hideSearchBar()
        self.searchText=searchBar.text
        parseData(self.searchText)

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("search q: \(self.searchText)")
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.delegate = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.firstTableView.dataSource=self
        self.firstTableView.delegate=self
        
        
        
        
        parseData(self.searchText)
        
    }
    deinit{
        if let superView = resultSearchController.view.superview
        {
            superView.removeFromSuperview()
        }
    }
    func parseData(queTxt: String){
        if elements.count>0{
            elements.removeAllObjects()
            self.firstTableView.reloadData()
        }
        let localquery = PFQuery(className:"Recipes")
        localquery.fromLocalDatastore()
        localquery.orderByAscending("createdAt")
        localquery.whereKey("name", containsString: queTxt)
        localquery.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) recipes.")
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
                        self.title="\(self.elements.count) matches found"
                    }
                }else{
                    print("no matches")
                    self.title="\(self.elements.count) matches found"

                }
            
            }else{
                print("error get search \(error?.userInfo)")
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
   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}