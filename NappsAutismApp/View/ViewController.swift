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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //FONCTION APPELÉE LORS D'UN CHANGEMENT DANS FIREBASE
    func onPlanningChanged(data: [String : Any]){
        DataManager.sharedInstance.saveTasks(tasksId: data["tasksId"] as! Array<DocumentReference>)
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



    
