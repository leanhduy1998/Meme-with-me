//
//  GetGameData.swift
//  Mememe
//
//  Created by Duy Le on 8/20/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class GetGameData {
    private static let yearMultiplyer = 365 * 24 * 60 * 60
    private static let monthMultiplyer = 30 * 24 * 60 * 60
    private static let dayMultiplyer = 24 * 60 * 60
    private static let hourMultiplyer = 60 * 60
    private static let minuteMultiplyer = 60
    
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
                return
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
        
        let year = components.year! * yearMultiplyer
        let month = components.month! * monthMultiplyer
        let day = components.day! * dayMultiplyer
        let hour = components.hour! * hourMultiplyer
        let minute = components.minute! * minuteMultiplyer
        let second = components.second!
        let gameDateString =  year + month + day + hour + minute + second
        return gameDateString
    }
    static func getTimeIntForPreviewTable(completionHandler:@escaping (_ timeArray: [Int], _ currentTime: Int) -> Void){
        getCurrentTimeInt { (currentTimeInt) in
            DispatchQueue.main.async {
                var timeArray = [Int]()
                timeArray.append(getIn24HoursInt(currentTimeInt: currentTimeInt))
                timeArray.append(get1WeekAgoInt(currentTimeInt: currentTimeInt))
                timeArray.append(get2WeekAgoInt(currentTimeInt: currentTimeInt))
                timeArray.append(get3WeekAgoInt(currentTimeInt: currentTimeInt))
                
                for x in 1...12{
                    timeArray.append(getXMonthAgoInt(x: x, currentTimeInt: currentTimeInt))
                }
                
                completionHandler(timeArray, currentTimeInt)
            }
        }
    }
    private static func getIn24HoursInt(currentTimeInt: Int)-> Int{
        return currentTimeInt - dayMultiplyer
    }
    private static func get1WeekAgoInt(currentTimeInt: Int) -> Int{
        return currentTimeInt - monthMultiplyer/4
    }
    private static func get2WeekAgoInt(currentTimeInt: Int) -> Int{
        return currentTimeInt - monthMultiplyer/2
    }
    private static func get3WeekAgoInt(currentTimeInt: Int) -> Int{
        return currentTimeInt - monthMultiplyer*3/4
    }
    private static func getXMonthAgoInt(x: Int,currentTimeInt: Int) -> Int{
        return currentTimeInt - monthMultiplyer*x
    }
}
