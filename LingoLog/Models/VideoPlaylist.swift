//
//  VideoPlaylist.swift
//  LingoLog
//
//  Created by Tristan Szakacs on 5/24/22.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class VideoPlaylist{
    var playlist = Array<YTVideo>()
    var timePerLang = [[String]]()
    var totalHours: Int
    var totalMins: Int
    var totalSecs: Int

    init(){
        totalHours = 0
        totalMins = 0
        totalSecs = 0
        
        var tmpList = [String]()
        for (value, language) in LanguageCodes.langCodes.codes {
            tmpList.removeAll()
            tmpList.append(language)
            tmpList.append(String(totalHours))
            tmpList.append(String(totalMins))
            tmpList.append(String(totalSecs))
            
            timePerLang.append(tmpList)
                            
        }
        print("Init of the model")
        print(timePerLang)
    }
    
    func getPlaylist() -> Array<YTVideo> {
        return playlist 
    }
    
    func setPlaylist(aPlaylist: Array<YTVideo>) {
        playlist = aPlaylist 
    }

    

    

    
}
