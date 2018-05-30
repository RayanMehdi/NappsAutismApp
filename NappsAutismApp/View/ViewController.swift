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
import WatchConnectivity

class ViewController: UIViewController {
    @IBOutlet weak var TestLabel: UILabel!
    
    var db: Firestore!
    
    var wcSession: WCSession?
    var wcSessionActivationCompletion : ((WCSession)->Void)?
    
    var watchSession: WCSession? {
        didSet {
            if let session = watchSession {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        addListener(collection: "Autiste", document: "zPe4zhDnFAUfllUaoIVl")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onPlanningChanged(data: String){
        //analyse planning
        //send to watch....etc
        self.TestLabel.text=data
        self.watchSession?.sendMessage(["showTask": data], replyHandler: nil)
    }

    func addListener(collection: String, document: String){
        db.collection(collection).document(document)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.onPlanningChanged(data: document.data()!["prenom"] as! String)
        }
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

    extension ViewController: WCSessionDelegate {
        
        //MARK: - WCSessionDelegate
        
        func send(key: String, value: Any) {
            if let session = wcSession, session.isReachable {
                session.sendMessage([key : value], replyHandler: nil)
            }
        }
        
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            if activationState == .activated {
                if let activationCompletion = wcSessionActivationCompletion {
                    activationCompletion(session)
                    wcSessionActivationCompletion = nil
                }
            }
        }
        
        func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            /*if let bpm = message["test"] as? String {
                print(bpm)
            }*/
        }
        
        func sessionDidBecomeInactive(_ session: WCSession) {
        }
        
        func sessionDidDeactivate(_ session: WCSession) {
        }
}

