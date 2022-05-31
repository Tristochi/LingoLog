//
//  YTVideo.swift
//  LingoLog
//
//  Created by Tristan Szakacs on 5/24/22.
//

import Foundation


class YTVideo {
    var vidTitle: String
    var defaultAudioLanguage: String
    var duration: String
    
    init( vidTitle: String,
          defaultAudioLanguage: String,
          duration: String) {
        self.vidTitle = vidTitle
        self.defaultAudioLanguage = defaultAudioLanguage
        self.duration = duration
    }
    
}
