//
//  DataManager.swift
//  JustDoIt
//
//  Created by iem on 30/05/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import Foundation
import CoreData

class DataManager{
    
    static let sharedInstance = DataManager()
    
    var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var dataFileUrl: URL {
        return documentDirectory.appendingPathComponent("tasks").appendingPathExtension("json")
    }
    
    var context: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    var cachedTasks = [Task]()
    
    private init() {
        loadData()
    }
    
    func delete(object: NSManagedObject){
        context.delete(object)
        saveData();
    }
    
    func saveData(){
        saveContext()
    }
    
    func loadData(){

        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            self.cachedTasks = try context.fetch(fetchRequest)
        }catch{
            debugPrint("Could not load the Tasks from CoreData")
        }
    }
    
    func save(tasks: Array<Task>){
        self.cachedTasks = tasks
        saveData()
    }
    
    // MARK: - Core Data stack
    
    var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "NappsAutismApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
