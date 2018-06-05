//
//  DataManager.swift
//  JustDoIt
//
//  Created by iem on 30/05/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import Foundation
import CoreData
import Firebase
import FirebaseFirestore

class DataManager{
    
    public var db: Firestore!
    
    var nextTask=Task(taskName: "ERREUR")
    static let sharedInstance = DataManager()
    
    var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var dataFileUrl: URL {
        return documentDirectory.appendingPathComponent("tasks").appendingPathExtension("json")
    }
    
//    var context: NSManagedObjectContext{
//        return persistentContainer.viewContext
//    }
//
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
    //db.settings = settings
    }
    
//    func delete(object: NSManagedObject){
//        context.delete(object)
//        saveData();
//    }
    
//    func saveData(){
//        saveContext()
//    }
    
    func saveTasks(tasksId: Array<DocumentReference>){
        var tasks = Array<Task>()
        var cpt=0
        for taskId in tasksId {
            print("CHEVRE \(taskId.path)")
            var path = taskId.path.components(separatedBy: "/")
            let docRef = db.collection(path[0]).document(path[1])
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    _ = document.data().map(String.init(describing:)) ?? "nil"
                    //let task = Task(taskName: document.data()!["taskName"] as! String)
                    tasks.append(Task(data: document.data()!, id: path[1]))
                    cpt = cpt+1
                    if(cpt == tasksId.count){
                        self.save(tasks: tasks)
                    }
                    //print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
//    func createTask(task: String)-> Task{
//        var newTask : Task = Task(context: DataManager.sharedInstance.context)
//        
//        return newTask
//    }
//
//    func loadData(){
//
//        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
//
//        do {
//            self.cachedTasks = try context.fetch(fetchRequest)
//            print("TACHE ACTUELLE : \(cachedTasks)")
//        }catch{
//            print("ERREUR, NO TASK")
//            debugPrint("Could not load the Tasks from CoreData")
//        }
//    }
    
    func save(tasks: Array<Task>){
        self.cachedTasks = tasks
        
        var currentDate=Date().timeIntervalSince1970
        
        var minTimestamp=getFormattedDate(timestamp: (cachedTasks[0].date?.dateValue())!).timeIntervalSince1970
        //createTimer()
        for i in cachedTasks{
            var timestampTask=getFormattedDate(timestamp: (i.date?.dateValue())!).timeIntervalSince1970
            var diff=timestampTask-currentDate
            if(diff>=0 && diff<=minTimestamp){
                minTimestamp=diff
                nextTask=i
            }
        }
        
        print("Next task to schedule: "+nextTask.taskName!)
        
        let date = getFormattedDate(timestamp: (nextTask.date?.dateValue())!)
         let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(sendTaskToWatch), userInfo: nil, repeats: false)
         RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc func sendTaskToWatch(){
        print("OK !!!!!!!!!!!!"+nextTask.taskName!)
        
    }

    func createTimer(){
        var closerTask=Task(taskName: "tmp")
        var minInterval=Double(100000000000)
        var currentDate=Date().timeIntervalSince1970
        for i in cachedTasks{
            var Value=getFormattedDate(timestamp: i.date?.dateValue() as! Date).timeIntervalSince1970
            if(Value-currentDate<minInterval){
                closerTask=i
                minInterval=Value-currentDate
            }
        }
        print(closerTask.taskName)
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
        var year=pathDate[0].components(separatedBy: "-")[0]
        var month=pathDate[0].components(separatedBy: "-")[1]
        var day=pathDate[0].components(separatedBy: "-")[2]
        
        //Task date
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeZone = NSTimeZone() as TimeZone
        dateFormatter2.locale = NSLocale.current
        dateFormatter2.dateFormat =  "yyyy-MM-dd'T'HH:mm"
        dateFormatter2.date(from: String(describing: timestamp))
        let strDate2 = dateFormatter2.string(from: timestamp as Date)
        var pathDate2 = strDate2.components(separatedBy: "T")
        var hour=pathDate2[1].components(separatedBy: ":")[0]
        var minutes=pathDate2[1].components(separatedBy: ":")[1]
        
        
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
        /*var formatter = DateFormatter()
        formatter.timeZone=TimeZone(abbreviation: "UTC +2:00")*/
        //var current=Calendar.current.date(bySettingHour: 18, minute: 00, second: 00, of: currentDate)
        
        //print(current)
        
        
        /*let date=timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm"
        dateFormatter.date(from: String(describing: date))
        let strDate = dateFormatter.string(from: date as Date)
        var pathDate = strDate.components(separatedBy: "T")
        var hour=pathDate[1].components(separatedBy: ":")[0]
        var minutes=pathDate[1].components(separatedBy: ":")[1]
        
        var currentDate = Date()
        let formatter=DateFormatter()
        formatter.dateFormat =  "yyyy-MM-dd"
        formatter.date(from: String(describing: currentDate))
        let strCurrentDate = formatter.string(from: currentDate as Date)
        
        var finalDate=strCurrentDate+"T"+pathDate[1]
        
        let dddaaattteee = dateFormatter.date(from: finalDate)
        let current = Date(timeIntervalSince1970: <#T##TimeInterval#>)
        return pathDate[1]*/
    }
    
}
