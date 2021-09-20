//
//  GITUsersListService.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 18/09/21.
//

import Foundation

class GITUsersListService {
    typealias UsersDataCompletion = ([User]?, APIError?) -> ()

    static func getUsersData(_ urlString: String, completion: @escaping UsersDataCompletion) {
        BaseApi.callGetService(urlString) { data, error in
            if let respData = data {
                do{
                    let decoder = JSONDecoder()
                    let usersData: GithubUsers = try decoder.decode(GithubUsers.self, from: respData)
                    completion(usersData.items, nil)
                }
                catch{
                    completion(nil, .invalidData)
                }
            }
            completion(nil, error)
        }
    }
}

