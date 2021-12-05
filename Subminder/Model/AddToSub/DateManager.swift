//
//  DateManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/12/1.
//

import UIKit

class DateManager {
    
    func convertDateToString(date: Date) -> String {
        
        let date = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func convertStringToDate(dateString: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")
        
        guard let dateToUpload = dateFormatter.date(from: dateString) else { return Date() }
        
        return dateToUpload
    }
}
