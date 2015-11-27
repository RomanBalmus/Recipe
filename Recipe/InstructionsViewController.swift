//
//  InstructionsViewController.swift
//  Recipe
//
//  Created by iOS on 25/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
class InstructionsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    var detailItem : AnyObject?
    var elements: NSMutableArray = []

    @IBOutlet weak var instrucTableView: UITableView!
    
    func getData() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            let cv = detail.relationForKey("instructionsId")
            //print("cv \(cv)")
            let qcv = cv.query()
            qcv.orderByDescending("createdAt")
            qcv.findObjectsInBackgroundWithBlock {
                (robjects:[PFObject]?, error: NSError?) -> Void in
                if let robjects = robjects   {
                    for robject in robjects{
                        //print("instruct \(robject)")
                        self.elements.addObject(robject)
                        robject.pinInBackground()

                        
                    }
                    
                    self.instrucTableView.reloadData()
                }
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.instrucTableView.dataSource=self
        self.instrucTableView.delegate=self
        
        self.instrucTableView.registerNib(UINib(nibName: "InstructionCell", bundle: nil), forCellReuseIdentifier: "instructionCell")

        self.instrucTableView.sectionHeaderHeight=UITableViewAutomaticDimension
        self.instrucTableView.estimatedRowHeight=126
        self.instrucTableView.rowHeight=UITableViewAutomaticDimension
        getData()

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
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("instructionCell") as! InstructionCell
        let instr = elements.objectAtIndex(indexPath.row) as! PFObject
        
        cell.titleLbl.text = instr.objectForKey("text") as? String
        let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
        }
        
        
        
        if let imgs = instr.objectForKey("images") as? NSMutableArray{
        for var index = 0; index < imgs.count; ++index {
            let urlstr = imgs.objectAtIndex(index) as! String
            let url = NSURL(string: urlstr)

            if index == 0{
                
                cell.imgOne.sd_setImageWithURL(url, completed: block)
            }
            if index == 1{
                cell.imgTwo.sd_setImageWithURL(url, completed: block)

            }
            if index == 2{
                cell.imgThree.sd_setImageWithURL(url, completed: block)

            }
        }
    }
        /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:1]]; // For GMT+1
        NSString *time = [formatter stringFromDate:[NSDate date]];*/
        return cell
    }
  

}