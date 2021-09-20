//
//  GITEnum.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 18/09/21.
//

import Foundation

enum APIError: String, Error {      // API error cases
    case invalidResponse = "Response Invlaid"
    case noData = "No Data"
    case failedRequest = "Request failed"
    case invalidData = "Invalid Data"
}
