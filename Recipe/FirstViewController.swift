//
//  FirstViewController.swift
//  Recipe
//
//  Created by iOS on 20/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import UIKit

class FirstViewController : UIViewController , UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate{
    let videos = generateRandomData()
    var resultSearchController : UISearchController!
    var elements: NSMutableArray = []
    var refreshControl:UIRefreshControl!
    var storedOffsets = [Int: CGFloat]()
    @IBOutlet weak var firstTableView: UITableView!
    var currentPage = 0
    var nextpage = 0
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
       /* self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation=false
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self;
            
            
            //self.navigationItem.titleView = controller.searchBar
            return controller
        })()*/
        // Do any additional setup after loading the view, typically from a nib.
        self.firstTableView.dataSource=self
        self.firstTableView.delegate=self
        
        let nib = UINib(nibName: "TodayRecipe", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! TodayRecipe

        
        view.headerLabel.text="fdfd"
        view.backgroundColor =  UIColor(red:72/255,green:141/255,blue:200/255,alpha:0.9)
        self.firstTableView.tableHeaderView=view
        self.firstTableView.sectionHeaderHeight=UITableViewAutomaticDimension
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.firstTableView.addSubview(refreshControl)
        
        
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
        
        let localquery = PFQuery(className:"Recipes")
        localquery.fromLocalDatastore()
        localquery.orderByAscending("createdAt")
        let lastWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYear, value: -1, toDate: NSDate(), options: NSCalendarOptions())!
                print(lastWeekDate)
        localquery.whereKey("createdAt", greaterThan: lastWeekDate)
        localquery.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) recipes.")
                if objects?.count > 0 {
                    if let objects = objects   {
                        for object in objects {
                            self.firstTableView.beginUpdates()
                            self.elements.insertObject(object, atIndex: 0)

                            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
                            
                            self.firstTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            self.firstTableView.endUpdates()
                            object.pinInBackground()

                            
                            
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
                                        self.firstTableView.beginUpdates()
                                        self.elements.insertObject(objectsy, atIndex: 0)
                                        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
                                        
                                        self.firstTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                                        self.firstTableView.endUpdates()
                                        objectsy.pinInBackground()
                                        NSUserDefaults.standardUserDefaults().setObject(objectsy.createdAt! as NSDate, forKey: "last_insert")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                       

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
                                self.firstTableView.beginUpdates()
                                self.elements.insertObject(objectr, atIndex: 0)
                                let indexPath = NSIndexPath(forRow: 0, inSection: 1)
                                
                                self.firstTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                                self.firstTableView.endUpdates()
                                 objectr.pinInBackground()
                                NSUserDefaults.standardUserDefaults().setObject(objectr.createdAt, forKey: "last_insert")
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
    
    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String?
    {
        if section == 0{
            return "sas11"
        }
        return "sas"
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
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
        if section==0{
            
            return videos.count
            
        }
        return elements.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section==0{
            let cell = tableView.dequeueReusableCellWithIdentifier("videoCell", forIndexPath: indexPath) as! VideoCell
           

            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        let recipe = elements.objectAtIndex(indexPath.row) as! PFObject
        cell.textLabel!.text = recipe.objectForKey("name") as? String
        
        
        /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:1]]; // For GMT+1
        NSString *time = [formatter stringFromDate:[NSDate date]];*/
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "firstDetail" {
            if let indexPath = self.firstTableView.indexPathForSelectedRow {
                let object = elements[indexPath.row] as! PFObject
                let controller = segue.destinationViewController as! FirstDetailViewController
                
                if controller.detailItem != nil{
                    controller.detailItem = nil
                }
                controller.detailItem = object

                
            }
        }
    }
    
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? VideoCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
     func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? VideoCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section==0{
            return 100
        }
        return UITableViewAutomaticDimension
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
extension FirstViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos[collectionView.tag].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cCell", forIndexPath: indexPath)
        
        cell.backgroundColor = videos[collectionView.tag][indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
    
}
