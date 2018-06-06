//
//  ViewController.swift
//  NappsAutismApp
//
//  Created by Thomas Chaboud on 28/05/2018.
//  Copyright © 2018 Thomas Chaboud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class ViewController: UIViewController {
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WatchManager.sharedInstance.delegate = self
        DataManager.sharedInstance.delegate = self
        addListener(collection: "Planning", document: "S9qp9mdbY2bCSylmpa7Q") //ajout du listener
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //FONCTION APPELÉE LORS D'UN CHANGEMENT DANS FIREBASE
    func onPlanningChanged(data: [String : Any]){
        DataManager.sharedInstance.saveTasks(tasksId: data["tasksId"] as! Array<DocumentReference>)
        //let autistId=String(data["autisteId"] as! Int)
       // self.TestLabel.text=autistId
        //POUR ENVOYER UN MESSAGE A LA MONTRE:
//        if(DataManager.sharedInstance.cachedTasks.count > 1){
//            WatchManager.sharedInstance.sendTasktoWatch(task: DataManager.sharedInstance.cachedTasks[0])
//        }else{
//            var taskTest = Task(taskId: "test", taskName: "CHEEEVRE", imgURL: "work")
//            WatchManager.sharedInstance.sendTasktoWatch(task: taskTest)
//        }
        
    }
    
    

    //AJOUT D'UN LISTENER SUR UNE COLLECTION FIREBASE
    func addListener(collection: String, document: String){
        DataManager.sharedInstance.db.collection(collection).document(document)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.onPlanningChanged(data: (document.data() )!)
        }
        
        //RECUP UN DOCUMENT SANS AJOUTER DE LISTENER:
        /*docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                self.TestLabel.text="Document data: \(dataDescription)"
            } else {
                print("Document does not exist")
            }
        }*/
    }
}

extension ViewController: WatchManagerDelegate, DataManagerDelegate{
    func logs(message: String){
        logTextView.text = logTextView.text! + " \n " + message
    }
    func logsCachedTasks(tasks: Array<Task>){
        logTextView.text = "Mis à jour FireBase" + " \n "
        for task in tasks {
            logTextView.text = logTextView.text! + task.getString() + " \n "
        }
    }
}



    
