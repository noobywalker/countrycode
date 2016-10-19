//
//  CountryAPI.swift
//  CountrisCode
//
//  Created by Waratnan Suriyasorn on 10/19/2559 BE.
//  Copyright © 2559 Waratnan Suriyasorn. All rights reserved.
//

import Foundation
import Moya

// MARK: - Provider setup

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}

let APIProvider = RxMoyaProvider<API>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

// MARK: - Provider support

private extension String {
    var urlEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public enum API {
    case all
    case search(String)
    case iso2Code(String)
    case iso3Code(String)
}

extension API: TargetType {
    public var baseURL: URL { return URL(string: "http://services.groupkt.com/country")! }
    public var path: String {
        switch self {
        case .all:
            return "/get/all"
        case .search:
            return "/search"
        case .iso2Code(let code):
            return "get/iso2code/\(code)"
        case .iso3Code(let code):
            return "get/iso3code/\(code)"
        }
    }
    
    public var method: Moya.Method {
        return .GET
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .search(let query):
            return ["text" : query]
        default:
            return nil
        }
    }
    
    public var task: Task {
        return .request
    }
    public var sampleData: Data {
        return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
    }

}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
