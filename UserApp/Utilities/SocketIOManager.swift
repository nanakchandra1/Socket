//
//  SocketManager.swift
//  WashApp
//
//  Created by apple on 05/07/17.
//  Copyright © 2017 saurabh. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

var SocketManegerInstance = SocketIOManager.instance

class SocketIOManager: NSObject {
    
    var socket: SocketIOClient?
    
    
    override init() {
        
        super.init()
        let token = CurrentUser.token ?? ""
        self.socket = SocketIOClient(socketURL: URL(string: socketUrl)!, config: [.connectParams(["token": token,"role":"user"]),.log(true), .forcePolling(true)])
        
    }
    
    static var instance = SocketIOManager()
    
    fileprivate var socketHandlerArr = [(((Void)->Void))]()
    typealias ObjBlock = @convention(block) () -> ()
    
    
    
    func connectSocket(handler:((Void)->Void)? = nil){
        
        
        if socket?.status == .connected {
            
            handler?()
            
            return
            
        } else {
            
            if let handlr = handler{
                
                if !socketHandlerArr.contains(where: { (handle) -> Bool in
                    
                    let obj1 = unsafeBitCast(handle as ObjBlock, to: AnyObject.self)
                    let obj2 = unsafeBitCast(handlr as ObjBlock, to: AnyObject.self)
                    
                    return obj1 === obj2
                    
                }){
                    
                    socketHandlerArr.append(handlr)
                }
            }
            
            socket?.connect(timeoutAfter: 5, withHandler: {
                
                
                if self.socket?.status == .connecting{
                    
                    print_debug("socket is still connecting")
                }
                
                if self.socket?.status != .connected{
                    self.connectSocket(handler: handler)
                }
                    
                else{
                    
                    handler?()
                }
            })
            
            socket?.on("connected", callback: { data, ack in
                
                NotificationCenter.default.post(name: .connetSocketNotificationName, object: self)
            })

            
            if socket?.status != .connecting{
                
                socket?.connect()
            }
        }
        
    }
    
    
//    func connectSocket(handler:((Void)->Void)? = nil){
//        
//        
//        if socket?.status == .connected {
//            
//            handler?()
//            
//            return
//            
//        } else {
//            
//            socket?.on("connected", callback: { data, ack in
//               // handler?()
//
//            })
//            
//            self.socket?.connect()
//
//        }
//        
//
//    }
    
    
    func closeConnection() {
        socket?.disconnect()
    }
    
    
    func on(_ event: String, handler: @escaping ((JSON) -> Void)){
        
        self.connectSocket { (Void) in

        self.socket?.on(event, callback: { (data, ack) in
            
            if !data.isEmpty{
            
                let json = data.first!
                
                handler(JSON(json))
                
            }
            
        })
    }
}
 
    
    func emit(_ event: String, requestParams: JSONDictionary){
    
        self.connectSocket { (Void) in
            
            self.socket?.emit(event, requestParams)
            
        }
    }
    
    
    fileprivate func checkIfSessionIsValid(data:[Any]){
        
        if data.count > 0, let dict = (data[0] as? [String:Any]), let code = dict["code"],let msg = dict["message"]{
            
            if "\(code)" == "269"{
                
                showToastWithMessage("\(msg)")
               // SocketManegerInstance.socket?.offAll()
                SocketManegerInstance.socket?.disconnect()
                //cleaeUserDefault()
                //sharedAppdelegate.goToLoginOption()
            }
            
        }
        
    }
    
}
