//
//  ToDoViewController.swift
//  Recipe
//
//  Created by iOS on 30/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation

class ToDoViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var elements: NSMutableArray = []
    @IBOutlet weak var firstTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstTableView.dataSource=self
        self.firstTableView.delegate=self
        let cell = self.firstTableView.dequeueReusableCellWithIdentifier("headCell") as! IngredHeadCell
        self.firstTableView.tableHeaderView = cell
        self.firstTableView.estimatedRowHeight = 44
        //cell.checkBtn.addTarget(self, action: "allOrNothing:", forControlEvents: .TouchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: Selector("allOrNothing:"))
        cell.addGestureRecognizer(tap)

    }
    func allOrNothing(sender: UITapGestureRecognizer){
        
        let mys = sender.view as! IngredHeadCell
        let check = mys.checkBtn
        check.check()

        
        var myarraytogo = [PFObject]()
        for obj in self.elements{
            if let parseObj = obj as? PFObject{
                if check.isChecked{
                parseObj["checked"] = true
                }else{
                    parseObj["checked"] = false

                }
                myarraytogo.append(parseObj)
            }
        }
        
       
       PFObject.saveAllInBackground(myarraytogo, block: {
            (success: Bool, error: NSError?) -> Void in
            print("succes: \(success)")
            self.firstTableView.reloadData()
        })
    }
    
    func parseMulti(objs: NSMutableArray){
        print("multi: \(objs.count)")
        for fgdfgdf in objs{
            let recobj = fgdfgdf as! PFObject
            let recipeque = PFQuery(className: "Composition")
            recipeque.whereKey("recipeId", equalTo: recobj)
            recipeque.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error: NSError?) -> Void in
                if let objects = objects   {
                    for object in objects {
                        
                        let rel = object.relationForKey("ingredientId").query()
                        rel.includeKey("compositionId")
                        rel.findObjectsInBackgroundWithBlock{
                            (ingreds:[PFObject]?, error2: NSError?) -> Void in
                            
                            print("ingreds \(ingreds)")
                            for ing in ingreds!{
                                
                                self.elements.addObject(ing)
                            }
                            
                            self.firstTableView.reloadData()
                        }
                    }
                }

            }
        }
        
    }
    func parseSingle(obj : PFObject){
        print("single: \(obj.objectId)")
            let recipeque = PFQuery(className: "Composition")
            recipeque.whereKey("recipeId", equalTo: obj)
            recipeque.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error: NSError?) -> Void in
                if let objects = objects   {
                    for object in objects {
                        
                        let rel = object.relationForKey("ingredientId").query()
                        rel.includeKey("compositionId")
                        rel.findObjectsInBackgroundWithBlock{
                            (ingreds:[PFObject]?, error2: NSError?) -> Void in
                            
                            print("ingreds \(ingreds)")
                            for ing in ingreds!{
                                
                                self.elements.addObject(ing)
                            }
                            
                            self.firstTableView.reloadData()
                        }
                    }
                }
                
            }
        


    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.elements.count
    }
 
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let instr = elements.objectAtIndex(section) as! PFObject

        return instr.objectForKey("name") as? String
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let instr = elements.objectAtIndex(indexPath.section) as! PFObject

      
            let cell = tableView.dequeueReusableCellWithIdentifier("ingredCell", forIndexPath: indexPath) as! IngredCell
      
        
            cell.titleLbl!.text = "\(instr.objectForKey("qnt_value") as! String) "+"\(instr.objectForKey("qnt_def") as! String) \n"+"\(((instr.objectForKey("compositionId") as! PFObject).objectForKey("name") as! String).lowercaseString)"
            //cell.checkBtn.addTarget(self, action: "clickedCheckBox:", forControlEvents: .TouchUpInside)
            /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:1]]; // For GMT+1
            NSString *time = [formatter stringFromDate:[NSDate date]];*/
        if let state = instr.objectForKey("checked") as? Bool{
            if state{
                cell.checkBtn.isChecked=true

            }else{
                cell.checkBtn.isChecked=false

            }
        }else{
            cell.checkBtn.isChecked=false
        }
            return cell
        
        
    }

  
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let instr = elements.objectAtIndex(indexPath.section) as! PFObject

        let cell = firstTableView.cellForRowAtIndexPath(indexPath) as! IngredCell
        cell.checkBtn.tag=indexPath.section
        print("click")
       cell.checkBtn.check()
       
     
        let query = PFQuery(className:"Ingredients")
        query.getObjectInBackgroundWithId(instr.objectId!) {
            (gameScore: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let gameScore = gameScore {
                gameScore["checked"] = cell.checkBtn.isChecked
                gameScore.saveInBackground()
                
                
                let header = self.firstTableView.tableHeaderView as! IngredHeadCell
                let hcche = header.checkBtn
                print("checked \(self.checkAllElements())")
                
                hcche.isChecked = self.checkAllElements()
            }
        }
        
        
        
       // cell.checkBtn.addTarget(self, action: "clickedCheckBox:", forControlEvents: .TouchUpInside)
    }
    
    func checkAllElements()->Bool{
        for obj in self.elements{
            let pobj = obj as! PFObject
            if pobj["checked"] as! Bool {
                return true
            }else{
                return false
            }
            
        }
        return false
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    

}
