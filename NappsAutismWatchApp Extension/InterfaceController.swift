//
//  InterfaceController.swift
//  NappsAutismWatchApp Extension
//
//  Created by Thomas Chaboud on 29/05/2018.
//  Copyright © 2018 Thomas Chaboud. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    @IBOutlet var taskTitle: WKInterfaceLabel!
    
    @IBOutlet var imgTask: WKInterfaceImage!
    var task : [String: String] = ["test": "Je suis un test"]
    var watchSession : WCSession?
    
    
    func showTask(data: [String: String]){
        taskTitle.setText(data["name"])
        imgTask.setImage(UIImage(named: data["image"]!))
//        self.watchSession?.sendMessage(["ReturnTask": "OK"], replyHandler: nil)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        watchSession = WCSession.default
        // Configure interface objects here.
        imgTask.setImage(UIImage(named: "eat"))
        //imgTask.setImage(#imageLiteral(resourceName: "beer"))
        taskTitle.setText("JE SUIS UN CASTOR")
    }
    
    @IBAction func checkTask() {
        self.watchSession?.sendMessage(["ReturnTask": "OK"], replyHandler: nil)
        self.dismiss()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if(WCSession.isSupported()){
            watchSession = WCSession.default
            watchSession!.delegate = self
            watchSession!.activate()
        }

    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension InterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("watch received app context: ", applicationContext)
        print(applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage")
        if let data = message["showTask"] as? [String: String] {
            self.showTask(data: data)
        }
    }
}
