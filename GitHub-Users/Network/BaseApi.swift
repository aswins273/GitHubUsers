//
//  BaseApi.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 18/09/21.
//

import Foundation

class BaseApi {
    typealias RequestCompletion = (_ data: Data?, _ error: APIError?) -> Void

    static func callGetService(_ urlString: String, completion: @escaping RequestCompletion) {
        guard let url = URL(string: urlString) else {
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {       // request failed
                    print("Failed request : \(error!.localizedDescription)")
                    completion(nil, .failedRequest)
                    return
                }
                guard let data = data else {        // no returned data
                    print("No data returned")
                    completion(nil, .noData)
                    return
                }
                guard let response = response as? HTTPURLResponse else {        // issue with response
                    print("Unable to process response")
                    completion(nil, .invalidResponse)
                    return
                }
                guard response.statusCode == 200 else {     // response other than 200
                    print("Failure response: \(response.statusCode)")
                    completion(nil, .failedRequest)
                    return
                }
                completion(data as Data?, nil)      // success response
            }
        }
        task.resume()
    }
}
