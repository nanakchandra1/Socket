////
////  NetworkAdapter.swift
////  Onboarding
////
////  Created by Neelam Yadav on 24/7/16.
////  Copyright © 2016 Appinventiv. All rights reserved.
////
//
//import Foundation
//import Alamofire
//import SwiftyJSON
//
//
//typealias JSONDictionaryAny = [String : Any]
//
//
//
//typealias SuccessResponse = (_ json : JSON) -> ()
//typealias FailureResponse = (_ error : NSError) -> ()
//
//
//
//final class NetworkAdapter {
//    
//    
//    static func GET(_ url : String, parameters : JSONDictionaryAny, success : SuccessResponse, failure : FailureResponse) {
//        
//        request(url, method: .get, parameters: parameters, encoding: ParameterEncoding., headers: <#T##HTTPHeaders?#>)
//        let req = Alamofire.request(.GET, url, parameters: parameters)
//        
//        if isLoggingEnabled {
//            req.logRequest()
//        }
//        
//        req.handleResponse(success: success, failure: failure)
//    }
//    
//    static func GET_HEADER(_ url : String, parameters : JSONDictionaryAny, success : SuccessResponse, failure : FailureResponse) {
//        
//        
//        let req = Alamofire.request(.GET, url, parameters: parameters, encoding: ParameterEncoding.URL, headers: headers)
//        //let req = Alamofire.request(.GET, url, parameters: parameters)
//        
//        if isLoggingEnabled {
//            req.logRequest()
//        }
//        
//        req.handleResponse(success: success, failure: failure)
//    }
//
//    
//    
//    static func POST(_ url : String, parameters : JSONDictionaryAny,header: [String:String], success : SuccessResponse, failure : FailureResponse) {
//        
//        request(url, method: .post, parameters: parameters, headers: header)
//        .responseJSON { (response) in
//            
//            if response.result.isSuccess{
//            
//                switch response.result{
//                
//                case .success(let data):
//                    
//                    let jsonResponse = response.result.value as? JSON
//                    SuccessResponse(data)
//                    
//                case .failure(let error):
//                
//                    FailureResponse(error)
//                
//                }
//            }
//        }
//    }
//    
//    
//    
//    static func POSTMultipart(_ url : String, parameters : JSONDictionaryAny,header: [String:String],
//        images : UIImage?, compression : CGFloat = 1, success : @escaping SuccessResponse, failure : @escaping FailureResponse) {
//        
//        upload(multipartFormData: { (data:  MultipartFormData, headers: headers) in
//            
//            
//            
//        }, to: URLConvertible, encodingCompletion: { (result:  SessionManager.MultipartFormDataEncodingResult) in
//            <#code#>
//        })
//        
//        
//        Alamofire.upload(.POST, url, headers: header, multipartFormData: { (data : MultipartFormData) -> Void in
//            
//            for (key, value) in parameters {
//                
//                print_debug(key)
//                print_debug(value)
//                
//                
//                data.appendBodyPart(data: "\(value)".dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
//            }
//            if images != nil{
//                guard let imageData = UIImageJPEGRepresentation(images!, compression) else { return }
//                data.appendBodyPart(data: imageData, name: "user_image", fileName: "image", mimeType: "image/png")
//            }
//            
//        }) { (result : Manager.MultipartFormDataEncodingResult) -> Void in
//            
//            switch result {
//                
//            case .Success(let req, _, _):
//                
//                if isLoggingEnabled {
//                    req.logRequest()
//                }
//                
//                req.handleResponse(success: success, failure: failure)
//                
//            case .Failure(let encodingError):
//                print(encodingError)
//            }
//        }
//    }
//    
//    // Logs
//    fileprivate static var isLoggingEnabled = true
//    
//    static func enableLogs() {
//        isLoggingEnabled = true
//    }
//    
//    static func disableLogs() {
//        isLoggingEnabled = false
//    }
//    
//}
//
//private extension Alamofire.Request {
//    
//    func logAndHandleRequest(success : @escaping SuccessResponse, failure : FailureResponse) -> Self {
//        return self.logRequest().handleResponse(success: success, failure: failure)
//    }
//    
//    func logRequest() -> Self {
//        
//        return self.responseJSON { response in
//            
//            logNetwork("** Request Latency ** \n\n \(response.timeline.latency) \n")
//            
//            logNetwork("** Request ** \n\n \(response.request) \n")  // original URL request
//            logNetwork("** Response ** \n\n \(response.response) \n") // URL response
//            
//            if let val = response.result.value {
//                
//                logNetwork("** Result ** \n\n \(val) \n")
//                
//            } else if let err = response.result.error {
//                
//                logNetwork("** Error ** \n\n \(err) \n")
//            }
//        }
//    }
//    
//    func handleResponse(success : @escaping SuccessResponse, failure : @escaping FailureResponse) -> Self {
//        
//        return self.responseJSON { response in
//            
//            if let value = response.result.value {
//                
//                success(json: JSON(value))
//                
//            } else if let error = response.result.error {
//                
//                failure(error: error)
//            }
//        }
//    }
//}
//
//private func logNetwork<T>(_ obj : T) {
//    print_debug(obj)
//}
