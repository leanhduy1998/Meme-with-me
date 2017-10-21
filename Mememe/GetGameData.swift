//
//  GetGameData.swift
//  Mememe
//
//  Created by Duy Le on 8/20/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class GetGameData {
    static func getCurrentTimeInt(completionHandler: @escaping (_ timeInt: Int) -> Void){
        getDateFromServer { (date) in
            completionHandler(self.getDateInt(date: date))
        }
    }
    
    private static func getDateFromServer(completionHandler: @escaping (_ date: Date) -> Void){
        serverTimeReturn { (getResDate) -> Void in
            let dFormatter = DateFormatter()
            dFormatter.timeZone = NSTimeZone(abbreviation: "EST")! as TimeZone
            dFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            
            let dateGet = dFormatter.string(from: getResDate!)
            
            let temp = dFormatter.date(from: dateGet)
            
            completionHandler(temp!)
        }
    }
    
    private static func serverTimeReturn(completionHandler:@escaping (_ getResDate: Date?) -> Void){
        let url = URL(string: "https://www.google.com/")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            if(httpResponse == nil){
                completionHandler(Date())
            }
            
            if let contentType = httpResponse!.allHeaderFields["Date"] as? String {
                
                let dFormatter = DateFormatter()
                dFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
                let serverTime = dFormatter.date(from: contentType)
                if serverTime == nil{
                    completionHandler(Date())
                }
                completionHandler(serverTime)
            }
        }
        
        task.resume()
    }
    
    static func getDateInt(date: Date) -> Int{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: (date))
        
        let year = components.year! * 365 * 24 * 60 * 60
        let month = components.month! * 30 * 24 * 60 * 60
        let day = components.day! * 24 * 60 * 60
        let hour = components.hour! * 60 * 60
        let minute = components.minute! * 60
        let second = components.second!
        let gameDateString =  year + month + day + hour + minute + second
        return gameDateString
    }
}
