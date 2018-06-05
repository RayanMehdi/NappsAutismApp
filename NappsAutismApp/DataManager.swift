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
    var cachedTasks = [Task]()

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
        createTimer()
        
    }

    func createTimer(){
        //getFormattedDate(timestamp: cachedTasks[0].date?.dateValue() as! NSDate)
    }
    
    func getFormattedDate(timestamp:NSDate)->String{
        let date=timestamp
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
        
        return pathDate[1]
    }
    
}
