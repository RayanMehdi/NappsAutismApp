//
//  Task.swift
//  NappsAutismApp
//
//  Created by iem on 01/06/2018.
//  Copyright © 2018 Thomas Chaboud. All rights reserved.
//

import Foundation

class Task: Codable{
    var date : Date?
    var frequency : String?
    var imgURL : String?
    var isChecked : Bool?
    var needANotif : Bool?
    var taskName : String?
    
    init(date: Date?, frequency: String?, imgURL: String?, isChecked: Bool?, needANotif: Bool?, taskName: String? ) {
        self.date = date
        self.frequency = frequency
        self.imgURL = imgURL
        self.isChecked = isChecked
        self.needANotif = needANotif
        self.taskName = taskName
    }
    init(data: [String: Any?]) {
        self.date = data["Date"] as! Date
        self.frequency = data["frequency"] as! String
        self.imgURL = data["imgURL"] as! String
        self.isChecked = data["isChecked"] as! Bool
        self.date = data["Date"] as! Date
        self.date = data["Date"] as! Date
        
    }
    init(taskName: String) {
        self.taskName = taskName
    }
    
    
//    required init?(_ map: Map) {
//        var ctx = NSManagedObjectContext.MR_defaultContext()
//        var entity = NSEntityDescription.entityForName("Task", inManagedObjectContext: ctx)
//        super.init(entity: entity!, insertIntoManagedObjectContext: ctx)
//
//        mapping(map)
//    }
//
//    func mapping(map: Map) {
//        date        <- map["date"]
//        frequency   <- map["frequency"]
//        imgURL     <- map["imgURL"]
//        isChecked    <- map["isChecked"]
//        needANotif   <- map["needANotif"]
//        taskName     <- map["taskName"]
//
//    }
    
}
