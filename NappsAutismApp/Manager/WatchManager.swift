//
//  WatchManager.swift
//  NappsAutismApp
//
//  Created by iem on 06/06/2018.
//  Copyright © 2018 Thomas Chaboud. All rights reserved.
//

import Foundation

import UIKit
import WatchConnectivity

class WatchManager : NSObject{
    static let sharedInstance = WatchManager()
    var wcSession: WCSession?
    var wcSessionActivationCompletion : ((WCSession)->Void)?
    var delegate : WatchManagerDelegate?
    
    var watchSession: WCSession? {
        didSet {
            if let session = watchSession {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    override init() {
        super.init()
        if(WCSession.isSupported()){
            watchSession = WCSession.default
            watchSession!.delegate = self
            watchSession!.activate()
        }
    }
    
    func sendTasktoWatch(task: Task){
        self.watchSession?.sendMessage(["showTask": task.getData()], replyHandler: nil)
    }
    
    func returnFromWatch(text: String){
        DataManager.sharedInstance.searchCloserTask()
        delegate?.logs(message: text)
    }
}

extension WatchManager: WCSessionDelegate {
    
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
                self.returnFromWatch(text: (message["ReturnTask"] as? String)!);
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
}

protocol WatchManagerDelegate : class {
    func logs(message: String)
}

