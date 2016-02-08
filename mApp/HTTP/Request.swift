//
//  Request.swift
//  mApp
//
//  Created by matouka-suzuki on 2015/11/18.
//  Copyright © 2016年 xxx All rights reserved.
//

import Alamofire
import ObjectMapper

protocol RequestProtocol: URLRequestConvertible {
    var baseURL: NSURL { get }
    var method: Alamofire.Method { get }
    var path: String { get }
    
    var parameters: [String: AnyObject] { get }
}

extension RequestProtocol {
    var baseURL: NSURL {
        return NSURL(string: "")!
    }
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var path: String {
        return ""
    }
    
    var parameters: [String : AnyObject]? {
        return nil
    }

    // URLRequestConvertible
    var URLRequest: NSMutableURLRequest {
        let paramStrs = parameters.map { key, value  -> String in
            let valueAsString = (value as? String) ?? "\(value)"
            return "\(key)=\(valueAsString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)"
        }
        var urlString = self.baseURL.absoluteString + self.path
        if paramStrs.count > 0 {
            urlString += "?" + paramStrs.joinWithSeparator("&")
            // パラメータ名の指定(key)がない場合は削除
            if let hasArgs = urlString.rangeOfString("?=") {
                urlString.removeRange(hasArgs)
            }
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        return request
    }
}

// MARK: ----- JSON取得リクエストクラス -----
protocol Request: RequestProtocol{
    typealias ResponseType
    func fromJson(json: AnyObject) -> Result<ResponseType, NSError>
}

extension Request {
    func fromJson(json: AnyObject) -> Result<ResponseType, NSError> {
        guard let value = json as? ResponseType else {
            return .Failure(Error.errorWithCode(1, failureReason: ""))
        }
        return .Success(value)
    }
}

// ObjectMapper処理
extension Request where ResponseType: Mappable{
    func fromJson(json: AnyObject) -> Result<ResponseType, NSError> {
        guard let value = Mapper<ResponseType>().map(json) else {
            return .Failure(Error.errorWithCode(2, failureReason: ""))
        }
        return .Success(value)
    }
}