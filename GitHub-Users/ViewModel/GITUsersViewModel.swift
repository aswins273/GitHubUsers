//
//  GITUsersViewModel.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 18/09/21.
//

import Foundation

public class GITUsersViewModel: NSObject {
    
    var userDetails = [User]()
    var searchText : String = "aswin"
    var currentPage : Int? = 0
    var isLoadingList : Bool? = false
    var repoCount: Int?
    var followersCount: Int?
    var sortText: String?
    var tableReloadsHandler: (() -> Void)?
    var errorHandler: ((_ errorMessage: String) -> Void)?

    init(searchText: String, currentPage: Int?, isLoading: Bool? ) {
        self.searchText = searchText
        self.currentPage = currentPage
        self.isLoadingList = isLoading
    }
    func fetchUsersList() {     // fetch users list
        let searchUrl = getSearchUrl()
        GITUsersListService.getUsersData(searchUrl) {[weak self] (usersData, error) in
            guard let self = self else {
                return
            }
            if let usersData = usersData {
                self.userDetails = usersData
                self.isLoadingList = false
                self.tableReloadsHandler?()
            }
            if let error = error {
                self.errorHandler?(error.rawValue)
            }
        }
    }
    func searchUsers(_ string: String?) -> Bool? {
        guard let query = string, query.trimmingCharacters(in: .whitespaces) != "", query.count >= 3 else {     // provide search if search text is greater than 3
            return false
        }
        currentPage = 0
        searchText = query
        fetchUsersList()
        return true
    }
    func loadMoreUsers() -> Bool? {     // pagination
        guard isLoadingList == false, let page = currentPage else {     // if not loading fetch users
            return false
        }
        isLoadingList = true
        currentPage = page + 1
        fetchUsersList()
        return true
    }
    func getSearchUrl() -> String {
        var urlString = searchUrl + "?q=\(searchText)"
        if let repo = repoCount {       // add reositry count
            urlString += "+repos:%3E\(repo)"
        }
        if let followers = followersCount {     // add followers count
            urlString += "+followers:%3E\(followers)"
        }
        if let sort = sortText {        // add sort value
            urlString += "&sort=\(sort)"
        }
        if let page = currentPage {     // add pagination
            let countReq = (page + 1) * 20
            urlString += "&per_page=\(countReq)"
        }
        return urlString
    }
}
