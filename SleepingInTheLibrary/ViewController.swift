//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    
    @IBAction func grabNewImage(sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    private func setUIEnabled(enabled: Bool) {
        photoTitleLabel.enabled = enabled
        grabImageButton.enabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    private func getImageFromFlickr() {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print(error)
                print("URL at time of error: \(url)")
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                }
            }
            
            if error == nil {
                
                if let data = data {
                    
                    let parsedResult: AnyObject!
                    do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    } catch {
                        displayError("Could not parse the data as JSON: '\(data)'")
                        return
                    }
                    
                    if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String : AnyObject],
                    photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String : AnyObject]] {
                        print(photoArray[0])
                    }
                }
            }
        }
        task.resume()
    }
    
    private func escapedParameters(parameters: [String:AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                let stringValue = "\(value)"
                
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
}






