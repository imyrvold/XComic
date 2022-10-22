//
//  ApiClient.swift
//  XComics
//
//  Created by Ivan C Myrvold on 22/10/2022.
//

import Foundation

struct ApiClient<ResourceType> where ResourceType: Decodable {
    let decoder = JSONDecoder()
    let method: RequestType
    let path: String
    let parameters: [String: Any]?
    let queryItems: [URLQueryItem]?
    let httpBody: Data?
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "CEST") ?? TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
    
    init(method: RequestType, path: String, parameters: [String: Any]? = nil, queryItems: [URLQueryItem]? = nil, httpBody: Data? = nil, dateFormatter: DateFormatter? = nil) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.queryItems = queryItems
        self.httpBody = httpBody
        if let dateFormatter = dateFormatter {
            self.dateFormatter = dateFormatter
        }
    }
 
    mutating func getData() async throws -> ResourceType {
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let call: APICall
        if let parameters = parameters {
            call = APICall(method: method, path: path, parameters: parameters, httpBody: httpBody)
        } else {
            call = APICall(method: method, path: path, httpBody: httpBody)
        }
        let data = try await call.getData()
        let json = String(decoding: try JSONSerialization.data(withJSONObject: JSONSerialization.jsonObject(with: data), options: [.prettyPrinted]), as: UTF8.self)
        print(json)
        let resource = try decoder.decode(ResourceType.self, from: data)
        
        return resource
    }
}
