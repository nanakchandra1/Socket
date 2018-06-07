//
//  NetworkEndpoints.swift
//  Onboarding
//
//  Created by Gurdeep Singh on 22/08/16.
//  Copyright © 2016 Gurdeep Singh. All rights reserved.
//

import Foundation


protocol NetworkEndpoint {
    var path : String { get }
}

let BASE_URL = "http://reusable.applaurels.com/base/v1"

enum UserEndpoint : NetworkEndpoint {
    
    case signup, login
    
    var path : String {
    
        switch self {
        
            case .signup : return "\(BASE_URL)/signup"
            case .login : return "\(BASE_URL)/login"
        }
    }
}

