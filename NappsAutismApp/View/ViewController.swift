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
        
        if(WCSession.isSupported()){
            watchSession = WCSession.default
            watchSession!.delegate = self
            watchSession!.activate()
        }
        
        addListener(collection: "Planning", document: "S9qp9mdbY2bCSylmpa7Q") //ajout du listener
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //FONCTION APPELÉE LORS D'UN CHANGEMENT DANS FIREBASE
    func onPlanningChanged(data: [String : Any]){
        //analyse planning
        //send to watch....etc
        let autistId=String(data["autisteId"] as! Int)
        self.TestLabel.text=autistId //test
        //SAVE IN CORE DATA
        
        //POUR ENVOYER UN MESSAGE A LA MONTRE:
        self.watchSession?.sendMessage(["showTask": autistId], replyHandler: nil)
    }
    
    func returnFromWatch(){
        self.TestLabel.text?.append("\nRECU PAR LA MONTRE")
    }

    //AJOUT D'UN LISTENER SUR UNE COLLECTION FIREBASE
    func addListener(collection: String, document: String){
        db.collection(collection).document(document)
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
        
        //GESTION DES MESSAGES RECUS PAR LA MONTRE
        func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            if (message["ReturnTask"] as? String) != nil {
                DispatchQueue.main.async {
                    self.returnFromWatch();
                }
            }
        }
        
        func sessionDidBecomeInactive(_ session: WCSession) {
        }
        
        func sessionDidDeactivate(_ session: WCSession) {
        }
}

