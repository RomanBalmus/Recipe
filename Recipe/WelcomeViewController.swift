//
//  WelcomeViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/21/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import Alamofire
import ParseFacebookUtilsV4


class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLogin(sender: UIButton) {
        
        
        
        
        
        
        
       ProgressHUD.show("Signing in...", interaction: false)
     /*   PFFacebookUtils.logInInBackgroundWithReadPermissions([ "email", "user_friends","public_profile","user_about_me"], block: { (user: PFUser?, error: NSError?) -> Void in
            if (user != nil) {
                if user![PF_USER_FACEBOOKID] == nil {
                    self.requestFacebook(user!)
                } else {
                    self.userLoggedIn(user!)
                }
            } else {
                if error != nil {
                    print("error \(error)")
                     let info = error!.userInfo as NSDictionary
                        print(info)
                    
                }
                ProgressHUD.showError("Facebook sign in error")
            }
        })*/
        
     /*   PFFacebookUtils.logInInBackgroundWithReadPermissions([ "email", "user_friends","public_profile","user_about_me"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }*/
        
       /* PFFacebookUtils.logInWithPermissions(["email", "user_friends"], /*block; added*/block: {
            (user: PFUser?, error: NSError?) -> Void in //switched ! to ?
            if user == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
                ProgressHUD.showError("Facebook sign in error")
                self.requestFacebook(user!)

            } else if user!.isNew { //inserted !
                NSLog("User signed up and logged in through Facebook!")
                self.userLoggedIn(user!)

            } else {
                NSLog("User logged in through Facebook! \(user!.username)")
                self.requestFacebook(user!)


            }
        })*/
        
        
        
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile","email"], block: { (user:PFUser?, error:NSError?) -> Void in
            
            
            if(error != nil)
            {
                //Display an alert message
                ProgressHUD.dismiss()
                let myAlert = UIAlertController(title:"Alert", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert);
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction);
                self.presentViewController(myAlert, animated:true, completion:nil);
                
                return
            }
            
            print(user)
            print("Current user token=\(FBSDKAccessToken.currentAccessToken().tokenString)")
            
            print("Current user id \(FBSDKAccessToken.currentAccessToken().userID)")
            
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    if(FBSDKAccessToken.currentAccessToken() != nil)
                    {
                        self.dofbrequest()
                        
                        
                    }
                } else {
                    print("User logged in through Facebook!")
                    self.userLoggedIn(user)
                    ProgressHUD.dismiss()
                    
                }
            }
           
            
           
            
            
            
            
        })
        

        
        
    }
    
    func dofbrequest(){
        // Do any additional setup after loading the view.
        
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        
        userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
            
            if(error != nil)
            {
                print("\(error.localizedDescription)")
                ProgressHUD.showError(error.localizedDescription)


                return
            }
            
            if(result != nil)
            {
                
                let userId:String = result["id"] as! String
                let userFirstName:String? = result["first_name"] as? String
                let userLastName:String? = result["last_name"] as? String
                let userEmail:String? = result["email"] as? String
                
                
                print("\(userEmail)")
                
                let myUser:PFUser = PFUser.currentUser()!
                
                // Save first name
                if(userFirstName != nil)
                {
                    myUser.setObject(userFirstName!, forKey: "first_name")
                    
                }
                
                //Save last name
                if(userLastName != nil)
                {
                    myUser.setObject(userLastName!, forKey: "last_name")
                }
                
                // Save email address
                if(userEmail != nil)
                {
                    myUser.setObject(userEmail!, forKey: "email")
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    // Get Facebook profile picture
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    
                    let profilePictureUrl = NSURL(string: userProfile)
                    
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    
                    if(profilePictureData != nil)
                    {
                        let profileFileObject = PFFile(data:profilePictureData!)
                        myUser.setObject(profileFileObject!, forKey: "profile_picture")
                    }
                    
                    
                    myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if(success)
                        {
                            print("User details are now updated")
                            self.userLoggedIn(myUser)
                            ProgressHUD.dismiss()
                        }
                        
                    })
                    
                    
                    
                }
                
                
                
                
                
                
                
            }
            
            
            
            
        }
        
        

    }
   /* func requestFacebook(user: PFUser) {
        let request = FBRequest.requestForMe()
        request.startWithCompletionHandler { (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                let userData = result as! [String: AnyObject]!
                print("userdata \(userData)")
                self.processFacebook(user, userData: userData)
                
                
                
                
                
            } else {
                PFUser.logOut()
                ProgressHUD.showError("Failed to fetch Facebook user data")
            }
        }
        

    
        
        
    
    }
    */
    
    
    
    func processFacebook(user: PFUser, userData: [String: AnyObject]) {
        let facebookUserId = userData["id"] as! String
        let link = "http://graph.facebook.com/\(facebookUserId)/picture"
       // let url = NSURL(string: link)
       // var request = NSURLRequest(URL: url!)
        let params = ["height": "200", "width": "200", "type": "square"]
        Alamofire.request(.GET, link, parameters: params).response() {
            (request, response, data, error) in
            
            
            if error == nil {
                var image = UIImage(data: data! as NSData)!
                
                if image.size.width > 280 {
                    image = Images.resizeImage(image, width: 280, height: 280)!
                }
                let filePicture = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
                filePicture!.saveInBackgroundWithBlock({ (success: Bool?, error: NSError?) -> Void in
                    if error != nil {
                        ProgressHUD.showError("Error saving photo")
                    }
                })
                
                if image.size.width > 60 {
                    image = Images.resizeImage(image, width: 60, height: 60)!
                }
                let fileThumbnail = PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
                fileThumbnail!.saveInBackgroundWithBlock({ (success: Bool?, error: NSError?) -> Void in
                    if error != nil {
                        ProgressHUD.showError("Error saving thumbnail")
                    }
                })
              let  email = userData["email"]
                if (email != nil){
                user[PF_USER_EMAILCOPY] = email
                }
                user[PF_USER_FULLNAME] = userData["name"]!
                user[PF_USER_FULLNAME_LOWER] = (userData["name"] as! String).lowercaseString
                user[PF_USER_FACEBOOKID] = userData["id"]
                user[PF_USER_PICTURE] = filePicture
                user[PF_USER_THUMBNAIL] = fileThumbnail
                user.saveInBackgroundWithBlock({ (succeeded: Bool?, error: NSError?) -> Void in
                    if error == nil {
                        self.userLoggedIn(user)
                    } else {
                        PFUser.logOut()
                         let info = error!.userInfo as NSDictionary
                            ProgressHUD.showError("Login error")
                            print(info["error"] as! String)
                        
                    }
                })
            } else {
                PFUser.logOut()
                 let info = error!.userInfo as NSDictionary
                    ProgressHUD.showError("Failed to fetch Facebook photo")
                    print(info["error"] as! String)
                
            }
        }
    }
    
    func userLoggedIn(user: PFUser) {
        PushNotication.parsePushUserAssign()
        ProgressHUD.showSuccess("Welcome back, \(user[PF_USER_FULLNAME])!")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
