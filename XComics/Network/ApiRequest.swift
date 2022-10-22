//
//  ApiRequest.swift
//  XComics
//
//  Created by Ivan C Myrvold on 22/10/2022.
//

import Foundation

public enum RequestType: String {
    case GET, POST, PUT, DELETE
}

struct APICall {
    let method: RequestType
    let path: String
    let parameters: [String: Any]
    let httpBody: Data?
    
    init(method: RequestType, path: String, parameters: [String: Any] = [:], httpBody: Data? = nil) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.httpBody = httpBody
    }
}

extension APICall {
    func getData(with baseURL: URL = URL(string: "https://xkcd.com")!) async throws -> Data {
        let session = URLSession.shared
        let request = urlRequest(with: baseURL)
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse {
            if (200...299).contains(response.statusCode) {
                return data
            } else if (500...599).contains(response.statusCode) {
                throw AppError.badRequest
            } else {
                throw AppError.apiRequestBadResponseCode(statusCode: response.statusCode)
            }
        }
        throw AppError.unknown
    }

}

extension APICall {
    func urlRequest(with baseURL: URL = URL(string: "https://xkcd.com")!) -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Failed to create url components")
        }
                
        guard let url = components.url else { fatalError("Failed to create url") }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let httpBody = self.httpBody {
            request.httpBody = httpBody
        } else if !self.parameters.isEmpty {
            let jsonData = try? JSONSerialization.data(withJSONObject: self.parameters)
            request.httpBody = jsonData
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let versionKey = kCFBundleVersionKey as String
        if let build = Bundle.main.object(forInfoDictionaryKey: versionKey) as? String, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue("elKompis/\(version).\(build) (iOS)", forHTTPHeaderField: "User-Agent")
        }
        
        return request
    }
}
