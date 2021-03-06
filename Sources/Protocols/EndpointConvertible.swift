//
//  EndpointConvertible.swift
//  P3NetworkKit
//
//  Created by Oscar Swanros on 6/19/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public protocol EndpointConvertible {
    var apiBase: String { get }
    
    func generateURL() -> URL?
    func generateURL(path: String?) -> URL?
    func generateURL(params: [String:String]?) -> URL?
}

extension EndpointConvertible {
    public var apiBase: String {
        return "https://httpbin.org"
    }
    
    public func generateURL() -> URL? {
        return URL(string: apiBase)
    }
    
    public func generateURL(path: String?) -> URL? {
        guard
            var url = generateURL(),
            let path = path
            else {
                return nil
        }
        
        url.appendPathComponent(path)
        return url
    }
    
    public func generateURL(params: [String:String]?) -> URL? {
        guard let url = generateURL(), let params = params else {
            return nil
        }
        
        return url.p3_append(params: params)
    }
}

public struct NullEndpoint: EndpointConvertible, Hashable {
    let identifier = "_kP3NullEndpointInstance"
    public var hashValue: Int {
        return identifier.hashValue
    }
}

public func ==(lhs: NullEndpoint, rhs: NullEndpoint) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
