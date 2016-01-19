//
//  Api.swift
//  Recipe
//
//  Created by iOS on 15/12/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation

var dict = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!)
var prodConfigs = dict!["AppConfig"] as! NSDictionary
var someUrl = prodConfigs["base_url"] as! NSString
var userAuth = prodConfigs["userAuth"] as! NSString
var passwordAuth = prodConfigs["passwordAuth"] as! NSString
typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>
typealias APICallback = ((NSDictionary?, NSError?) -> ())
let loginString = NSString(format: "%@:%@", userAuth, passwordAuth)
let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary?)
    func didReceiveAPIError(error: NSError)

}
class Api: NSObject, NSURLConnectionDataDelegate {
    
    var delegate: APIControllerProtocol?
    
    init(delegate: APIControllerProtocol?) {
        self.delegate = delegate
    }
    
    
    func getProductList(parameters: NSDictionary, callback: APICallback){
        print(dict)
        
        
        
        self.makeHTTPPostRequest(parameters,url: "mob/products_to_activate_list.php?"){
            (data, error) -> Void in
            if (error == nil){
                //self.delegate?.didReceiveAPIResults(data)
                callback(data,nil)
            }else{
                //self.delegate?.didReceiveAPIError(error!)
                callback(nil,error!)


            }
        }
    }
    
    func makeHTTPPostRequest(parameters: NSDictionary, url: NSString, callback: APICallback){
        
        let urlObject = NSURL(string: (someUrl as String)  + (url as String) as String)
        var request = NSMutableURLRequest(URL: urlObject!)
        request = self.buildRequestHeaders(request)
        request.HTTPMethod = "POST"
        
        htttpRequest(request){
            (data, error) -> Void in
            callback(data, error)
        }
    }
    
    func makeHTTPGetRequest(url: NSString, callback: APICallback){
        
        let urlObject = NSURL(string: (someUrl as String)  + (url as String) as String)
        var request = NSMutableURLRequest(URL: urlObject!)
        request = self.buildRequestHeaders(request)
        request.HTTPMethod = "GET"
        
        htttpRequest(request){
            (data, error) -> Void in
            callback(data, error)
        }
    }
    
    func htttpRequest(request: NSURLRequest!, callback: APICallback) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error ) -> Void in
            if error != nil {
                callback(nil, error!)
            } else {
           
                do {
                let jsonResult: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options:    NSJSONReadingOptions.MutableContainers)
                
                    if let nsDictionaryObject = jsonResult as? NSDictionary {
                            callback(nsDictionaryObject, nil)
                      
                    }
            } catch {
                print("Error: cannot create JSON from post")

            }
                
            }
        }
        task.resume()
    }
    
    func buildRequestHeaders(request: NSMutableURLRequest) -> NSMutableURLRequest{
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        return request
    }
    
}
