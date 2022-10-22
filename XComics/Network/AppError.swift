//
//  AppError.swift
//  XComics
//
//  Created by Ivan C Myrvold on 22/10/2022.
//

import Foundation

enum AppError: LocalizedError {
    case unknown
    case apiRequestFailed(error: Error)
    case apiRequestFailedWithMessage(errorMessage: String)
    case apiRequestBadResponseCode(statusCode: Int)
    case badRequest

    var localizedDescription: String {
        let description: String
        switch self {
        case .badRequest:
            description = String(localized: "general_error_message")
        case .unknown:
            description = "unknown"
        case .apiRequestFailed(let error):
            description = "api request failed with error: \(error.localizedDescription)"
        case .apiRequestBadResponseCode(let code):
            description = "api request failed with error code: \(code)"
        case .apiRequestFailedWithMessage(let errorMessage):
            description = "api request failed with message: \(errorMessage)"
        }
        
        return description
    }
}
