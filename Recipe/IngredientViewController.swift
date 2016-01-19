//
//  IngredientViewController.swift
//  Recipe
//
//  Created by iOS on 25/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
class IngredientViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    var detailItem : AnyObject?
    var elements: NSMutableArray = []

   

    
    
    let doseLbl = UILabel()
    @IBOutlet weak var ingredTableView: UITableView!
    
    func getData() {

        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            let cv = detail.relationForKey("compositionId") 
            let qcv = cv.query()
            qcv.orderByAscending("createdAt")
            qcv.findObjectsInBackgroundWithBlock {
                (robjects:[PFObject]?, error: NSError?) -> Void in
                if let robjects = robjects   {
                    for robject in robjects{
                        let compos = Compos(compos: robject)

                        let ingrRel = robject.relationForKey("ingredientId")
                        let ingrque = ingrRel.query()
                        ingrque.findObjectsInBackgroundWithBlock{
                            (ingObjcts:[PFObject]?,error2: NSError?) -> Void in
                            
                            if let ingObjcts = ingObjcts{
                                
                                for ingrd in ingObjcts{

                                    compos.addIngredient(ingrd)

                                }
                                
                                self.ingredTableView.reloadData()

                              
                            }
                            
                        }
                        
                        self.elements.addObject(compos)

                    }
                }
                
            }
        }
    }
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.ingredTableView.dataSource=self
        //self.ingredTableView.delegate=self
        let rect = CGRectMake(0, 0, self.view.frame.size.width, 44)
         doseLbl.frame=rect
        
        self.doseLbl.text = "Dosi per \((self.detailItem as! PFObject).valueForKey("dose") as! String)"

        self.ingredTableView.tableHeaderView=doseLbl
       self.ingredTableView.sectionIndexBackgroundColor = UIColor.orangeColor()
        self.ingredTableView.registerNib(UINib(nibName: "IngredientCell", bundle: nil), forCellReuseIdentifier: "ingredientCell")
        self.ingredTableView.sectionHeaderHeight=UITableViewAutomaticDimension
        self.ingredTableView.estimatedRowHeight=44
        self.ingredTableView.rowHeight=UITableViewAutomaticDimension
        
        getData()

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return (self.elements[section] as! Compos).ingredients.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.elements.count
    }
    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String?
    {
        let compos = (self.elements[section] as! Compos).compos
        
        return compos.valueForKey("name") as? String
        
    }
     func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // This changes the header background
        view.tintColor = UIColor.orangeColor()
        
        // Gets the header view as a UITableViewHeaderFooterView and changes the text colour
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.whiteColor()
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ingredientCell", forIndexPath: indexPath) as! IngredientCell
        let ingredient = (self.elements[indexPath.section] as! Compos).ingredients[indexPath.row]
        //let recipe = elements.objectAtIndex(indexPath.row) as! PFObject
        
        cell.titleLbl.text = "\(ingredient.objectForKey("name") as! String)\n"+"\(ingredient.objectForKey("qnt_value") as! String) "+"\(ingredient.objectForKey("qnt_def") as! String) "

        /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:1]]; // For GMT+1
        NSString *time = [formatter stringFromDate:[NSDate date]];*/
        return cell
    }
    
    
    
    //MARK section model
    
    // custom type to represent table sections
    class Compos {
        var ingredients: [PFObject] = []
        let compos: PFObject

        init(compos: PFObject) {
            self.compos = compos
        }
        func addIngredient(ingredient: PFObject) {
            self.ingredients.append(ingredient)
        }
    }


}