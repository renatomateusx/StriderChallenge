//
//  Utils.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 30/08/22.
//

import Foundation


class Utils {
    
    static func getDateFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateStyle = .short
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    static func getJoinedDate(date: Date) -> String {
//        MMM d, h:mm a
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        dateFormatter.dateStyle = .short
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}
