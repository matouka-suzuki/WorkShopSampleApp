//
//  API.swift
//  mApp
//
//  Created by matouka-suzuki on 2015/11/18.
//  Copyright © 2016年 xxx All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class API {
    class func call<T: Request, V where T.ResponseType == V>(request: T, completion: Result<V,NSError> -> Void) -> Alamofire.Request{
        return Alamofire.request(request).responseJSON { response -> Void in
            switch response.result{
            case .Success(let json):
                let data = request.fromJson(json)
                completion(data)
                break
                
            case .Failure(let error):
                let result = Result<V, NSError>.Failure(error)
                completion(result)
                break
            }
        }
    }
}
