//
//  DataManager.swift
//  JustDoIt
//
//  Created by iem on 30/05/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class DataManager{
    
    public var db: Firestore!
    
    var nextTask=Task(taskName: "ERREUR")
    static let sharedInstance = DataManager()
    var delegate : DataManagerDelegate?
    var timer: Timer?
    
    var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var dataFileUrl: URL {
        return documentDirectory.appendingPathComponent("tasks").appendingPathExtension("json")
    }
    
    
    public var cachedTasks = [Task]()

    private init() {
        initFirebase()
       // loadData()
    }
    
    private func initFirebase(){
    let settings = FirestoreSettings()
    settings.areTimestampsInSnapshotsEnabled = true
    Firestore.firestore().settings = settings
    db = Firestore.firestore()
    }
    
    func saveTasks(tasksId: Array<DocumentReference>){
        var tasks = Array<Task>()
        var cpt=0
        for taskId in tasksId {
            print("\(taskId.path)")
            var path = taskId.path.components(separatedBy: "/")
            let docRef = db.collection(path[0]).document(path[1])
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    _ = document.data().map(String.init(describing:)) ?? "nil"
                    tasks.append(Task(data: document.data()!, id: path[1]))
                    cpt = cpt+1
                    if(cpt == tasksId.count){
                        self.save(tasks: tasks)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func save(tasks: Array<Task>){
        self.cachedTasks = tasks
        delegate?.logsCachedTasks(tasks: cachedTasks)
        searchCloserTask()
    }
    
    func searchCloserTask(){
        var isTaskTomorrow=false
        let currentDate=Date().timeIntervalSince1970
        
        var minTimestamp=getFormattedDate(timestamp: (cachedTasks[0].date?.dateValue())!).timeIntervalSince1970
        //createTimer()
        for i in cachedTasks{
            let timestampTask=getFormattedDate(timestamp: (i.date?.dateValue())!).timeIntervalSince1970
            let diff=timestampTask-currentDate
            if(diff>=0 && diff<=minTimestamp){
                minTimestamp=diff
                nextTask=i
            }
        }
        
        var minTask=Double(0)
        if(nextTask.taskName=="ERREUR"){
            for i in cachedTasks{
                let timestampTask=getFormattedDate(timestamp: (i.date?.dateValue())!).timeIntervalSince1970
                let diff=timestampTask-currentDate
                if(diff<minTask){
                    minTask=diff
                    isTaskTomorrow=true
                    nextTask=i
                }
            }
        }
        
        print("Next task to schedule: "+nextTask.taskName!)
        if let timer = timer {
            if(timer.isValid){
                timer.invalidate()
            }
        }
        let date = getFormattedDate(timestamp: (nextTask.date?.dateValue())!)
        
        if(isTaskTomorrow){
            timer = Timer(fireAt: date.addingTimeInterval(TimeInterval(86400)), interval: 0, target: self, selector: #selector(sendTaskToWatch), userInfo: nil, repeats: false)
        }else{
            timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(sendTaskToWatch), userInfo: nil, repeats: false)
        }
        
        
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    @objc func sendTaskToWatch(){
        WatchManager.sharedInstance.sendTasktoWatch(task: nextTask)
    }
    
    func getFormattedDate(timestamp:Date)->Date{
        //Current date
        let date=Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm"
        dateFormatter.date(from: String(describing: date))
        let strDate = dateFormatter.string(from: date as Date)
        var pathDate = strDate.components(separatedBy: "T")
        let year=pathDate[0].components(separatedBy: "-")[0]
        let month=pathDate[0].components(separatedBy: "-")[1]
        let day=pathDate[0].components(separatedBy: "-")[2]
        
        //Task date
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeZone = NSTimeZone() as TimeZone
        dateFormatter2.locale = NSLocale.current
        dateFormatter2.dateFormat =  "yyyy-MM-dd'T'HH:mm"
        dateFormatter2.date(from: String(describing: timestamp))
        let strDate2 = dateFormatter2.string(from: timestamp as Date)
        var pathDate2 = strDate2.components(separatedBy: "T")
        let hour=pathDate2[1].components(separatedBy: ":")[0]
        let minutes=pathDate2[1].components(separatedBy: ":")[1]
        
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        dateFormatter.locale = NSLocale.current
        dateComponents.timeZone = TimeZone(secondsFromGMT: 7200)
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(minutes)
        let userCalendar = Calendar.current
        let someDateTime = userCalendar.date(from: dateComponents)
        
        
        
        return someDateTime!
    }
    
    func modifTaskInstant(task : Task){
        db.collection("Message").document(task.taskId!).setData([
            "imgURL": task.imgURL!,
            "isFirstTime": false,
            "taskName" : task.taskName! ], merge: true)
        
    }
    
}

protocol DataManagerDelegate : class {
    func logsCachedTasks(tasks : Array<Task>)
}
