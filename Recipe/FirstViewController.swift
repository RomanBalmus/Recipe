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
        for var i = 0; i <= 500; i++ {
            allObjectArray.addObject(i)
        }
        elements.addObjectsFromArray(allObjectArray.subarrayWithRange(NSMakeRange(0, 20)))
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
        
        cell.textLabel!.text = "cell"
        return cell
    }
    
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        nextpage = elements.count - 5
        if indexPath.row == nextpage {
            currentPage++
            nextpage = elements.count - 5
            elements.addObjectsFromArray(allObjectArray.subarrayWithRange(NSMakeRange(currentPage, 20)))
            tableView.reloadData()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

