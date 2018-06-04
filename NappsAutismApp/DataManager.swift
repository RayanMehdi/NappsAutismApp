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
        for taskId in tasksId {
            print("CHEVRE \(taskId.path)")
            var path = taskId.path.components(separatedBy: "/")
            let docRef = db.collection(path[0]).document(path[1])
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    //let task = Task(taskName: document.data()!["taskName"] as! String)
                    tasks.append(Task(data: document.data()!, id: path[1]))
                    //print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
            


            
        }
        save(tasks: tasks)
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
        print(cachedTasks.count)
        if(cachedTasks.count > 1){
            print(cachedTasks[0].taskName)
        }
    }

    
}
