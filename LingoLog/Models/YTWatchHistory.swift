//
//  YTWatchHistory.swift
//  LingoLog
//
//  Created by Tristan Szakacs on 5/24/22.
//

import Foundation
import UIKit

class YTWatchHistory {
    
    
    func getData(completionHandler: (()->())? = nil ) {
        let theURL = createURL()
        print("Got a URL")
        
        parseJSON(theURL: theURL, completionHandler: completionHandler)
    }
    
    func createURL() ->URL? {
        //build url for watch history
        let baseURL = "https://www.googleapis.com/youtube/v3"
        var urlComponents = URLComponents(string: baseURL)
        var queryItemArray = Array<URLQueryItem>()
        queryItemArray.append(URLQueryItem(name: "channels?part", value: "contentDetails"))
        queryItemArray.append(URLQueryItem(name: "mine", value: "true"))
        queryItemArray.append(URLQueryItem(name: "key", value: GlobalConstants.ClientID.APIKey))
    
        urlComponents?.queryItems = queryItemArray
        //print("Return URL is \(urlComponents?.string)")
        
        var newURL = urlComponents!.string
        
        if let i = newURL!.firstIndex(of: "?") {
            //print(newURL![i])
            newURL!.insert("/", at: i)
            let i = newURL!.firstIndex(of: "?")
            newURL!.remove(at: i!)
            //print(newURL)
        }
        var newURLComponents = URLComponents(string: newURL!)
        
        print("New URL is \(newURLComponents?.string)")
        /*
        if let i = urlComponents!.string!.firstIndex(of: "?") {
            
            urlComponents!.string!.insert("?", at: i)
            print(urlComponents!.string![i])
            print(urlComponents!.string)
        }
        */
        
        return newURLComponents?.url
    }
    
    func parseJSON(theURL: URL?, completionHandler: (()->())?) {
        if theURL == nil {
            return
        }
        
        let session = URLSession(configuration: .ephemeral)
        let dataTask = session.dataTask(with: theURL!) {
            (data, _, error) in
            if let actualError = error {
                print("Didn't work")
            } else if let actualData = data{
                print("The data is \(actualData)")
            }
        }
        dataTask.resume()
        print("done running dataTask")
        
    }

}
