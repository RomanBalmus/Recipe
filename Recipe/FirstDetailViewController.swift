//
//  FirstDetailViewController.swift
//  Recipe
//
//  Created by iOS on 23/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class FirstDetailViewController: UIViewController, CAPSPageMenuDelegate {
   var detailItem : AnyObject?
    var currentController = UIViewController()

    func initPageMenu(object: AnyObject){
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        let info : InfoViewController = InfoViewController(nibName: "InfoViewController", bundle: nil)  //info
        info.title = "INFO"
        info.detailItem=object
        controllerArray.append(info)
        
        let ingredients : IngredientViewController = IngredientViewController(nibName: "IngredientViewController", bundle: nil) //ingredients
        ingredients.title = "INGREDIENTI"
        ingredients.detailItem=object
        controllerArray.append(ingredients)
       
        let instruction : InstructionsViewController = InstructionsViewController(nibName: "InstructionsViewController", bundle: nil) //instruction
        instruction.title = "ISTRUZIONI"
        instruction.detailItem=object
        controllerArray.append(instruction)
        
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .MenuItemSeparatorWidth(4.3),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorPercentageHeight(0.1),
            .MenuItemFont(UIFont(name: "HelveticaNeue", size: 13.0)!),
            .MenuHeight(40.0),
            .CenterMenuItems(true)
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
      let  pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        pageMenu.bottomMenuHairlineColor=UIColor.randomColor()
        pageMenu.menuItemSeparatorColor=UIColor.randomColor()
        pageMenu.unselectedMenuItemLabelColor=UIColor.randomColor()
        pageMenu.selectedMenuItemLabelColor=UIColor.randomColor()
        pageMenu.selectionIndicatorColor=UIColor.randomColor()
        pageMenu.scrollMenuBackgroundColor=UIColor.randomColor()
        pageMenu.viewBackgroundColor=UIColor.randomColor()
        pageMenu.menuScrollView.backgroundColor=UIColor.randomColor()
        pageMenu.delegate=self
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.addChildViewController(pageMenu)
        self.view.addSubview(pageMenu.view)
        
        pageMenu.didMoveToParentViewController(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let saveBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "buttonMethod3")
        
       // let todo = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "buttonMethod2")
        
        let buttons : NSArray = [saveBtn/*, todo*/]
        
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
        
        
        self.initPageMenu(detailItem!)

       // self.configureView()
        
        
        
    }
    func buttonMethod3(){
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Aggiungi a preferiti", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("preferiti")
            optionMenu.dismissViewControllerAnimated(true, completion: nil)

            self.buttonMethod()
        })
        let saveAction = UIAlertAction(title: "Aggiungi alla lista spesa", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("spesa")
            
            optionMenu.dismissViewControllerAnimated(true, completion: nil)
           self.buttonMethod2()

        })
        
        //
        let cancelAction = UIAlertAction(title: "Annulla", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
            optionMenu.dismissViewControllerAnimated(true, completion: nil)
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    func buttonMethod() {
        print("save")
        
        let usr = PFUser.currentUser()!
        let rel = usr.relationForKey("Favorites")
        rel.addObject(self.detailItem as! PFObject)
        usr.saveInBackground()
       
        
    }
    
    func buttonMethod2() {
        print("todo")
        
        let tdobj = self.detailItem as! PFObject
        
        let usr = PFUser.currentUser()!
        let rel = usr.relationForKey("toDoList")
        
        let nobj = PFObject(className: "ToDo")
        nobj["done"]=false
        nobj.setObject(tdobj, forKey: "recipeId")
        
        nobj.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
            if (success) {
                print("done")
                rel.addObject(nobj)
                nobj.pinInBackground()

                usr.saveInBackground()
                
            } else {
                // Error saving message
            }
        }
      
        
        
        
    }
    
    func willMoveToPage(controller: UIViewController, index: Int){
        self.currentController = controller
        print("ctrlwill: \(controller)")

    }
    
    func didMoveToPage(controller: UIViewController, index: Int){
        self.currentController = controller
        print("ctrldid: \(controller)")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
public extension UIWindow {
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.opaque, 0.0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
