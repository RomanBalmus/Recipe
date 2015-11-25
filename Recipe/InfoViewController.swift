//
//  InfoViewController.swift
//  Recipe
//
//  Created by iOS on 25/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation


class InfoViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    var detailItem : AnyObject?
    var elements: NSMutableArray = []

    @IBOutlet weak var infoTableView: UITableView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoTableView.dataSource=self
        self.infoTableView.delegate=self
        
        let nib = UINib(nibName: "TodayRecipe", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! TodayRecipe
        
        let obj = self.detailItem as! PFObject
        view.headerLabel.text=obj.valueForKey("name") as? String
        view.backgroundColor =  UIColor(red:72/255,green:141/255,blue:200/255,alpha:0.9)
        self.infoTableView.tableHeaderView=view
        self.infoTableView.registerNib(UINib(nibName: "InfoCell", bundle: nil), forCellReuseIdentifier: "infoCell")
        self.infoTableView.sectionHeaderHeight=UITableViewAutomaticDimension
        self.infoTableView.estimatedRowHeight=44
        self.infoTableView.rowHeight=UITableViewAutomaticDimension
        elements.addObject(obj)
        self.infoTableView.reloadData()

        
        
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("infoCell") as! InfoCell

        let recipe = elements.objectAtIndex(indexPath.row) as! PFObject
        cell.titleLbl.text = recipe.valueForKey("info") as? String
        
        
        /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:1]]; // For GMT+1
        NSString *time = [formatter stringFromDate:[NSDate date]];*/
        return cell
    }
   
    
}