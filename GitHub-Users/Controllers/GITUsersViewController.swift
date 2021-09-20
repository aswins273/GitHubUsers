//
//  ViewController.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 17/09/21.
//

import UIKit

class GITUsersViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var usersTableView: UITableView!
    @IBOutlet var paginationIndicator: UIActivityIndicatorView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var noUserLabel: UILabel!
    
    @IBOutlet var filterView: UIView!
    @IBOutlet var sortView: UIView!
    @IBOutlet var repoValueLabel: UILabel!
    @IBOutlet var followerValueLabel: UILabel!
    @IBOutlet var sortButtons: [UIButton]!

    var viewModel = GITUsersViewModel(searchText: "", currentPage: 0, isLoading: false)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setHandlers()
        setupPullToRefresh()
    }

}

//MARK: View Datasource Methods
extension GITUsersViewController {
    func setupView() {
        usersTableView.register(UINib(nibName: "GITUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "usertableviewcell")
        let searchIndicator = UIActivityIndicatorView(style: .medium)
        searchBar.addSubview(searchIndicator)
        searchBar.textField?.delegate = self
        self.title = "Users"
    }
    func setupPullToRefresh() {     // adding pull to refresh option
        if #available(iOS 10.0, *) {
            usersTableView.refreshControl = refreshControl
        } else {
            usersTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshUserDetails(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Latest Data ...", attributes: nil)
    }
    func setHandlers() {        // view model handlers
        viewModel.tableReloadsHandler = {[weak self] in
            guard let vc = self else {return}
            vc.searchBar.isLoading = false
            vc.activityIndicator.stopAnimating()
            vc.paginationIndicator.stopAnimating()
            vc.refreshControl.endRefreshing()
            vc.usersTableView.reloadData()
            vc.noUserLabel.text = "No user found"
            vc.noUserLabel.isHidden = vc.viewModel.userDetails.count == 0 ? false : true
        }
        viewModel.errorHandler = { [weak self] errorMessage in
            guard let vc = self else {return}
            vc.searchBar.isLoading = false
            vc.activityIndicator.stopAnimating()
            vc.paginationIndicator.stopAnimating()
            vc.refreshControl.endRefreshing()
            vc.showAlert(message: errorMessage)
        }
    }
    @objc private func refreshUserDetails(_ sender: Any) {      // pull to refresh action
        viewModel.fetchUsersList()
    }
    func fetchUpdatedUsers() {      // update users data
        activityIndicator.startAnimating()
        viewModel.fetchUsersList()
    }
    func showAlert(message: String) {       // alert on api call error
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { action in
            self.viewModel.fetchUsersList()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Tableview Datasource Methods
extension GITUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userDetails.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "usertableviewcell")) as?  GITUsersTableViewCell
        let user = viewModel.userDetails[indexPath.row]
        cell?.configure(title: user.login, imageUrl: user.avatarUrl)
        return cell!
    }
}

// MARK: Tableview Delegate Methods
extension GITUsersViewController: UITableViewDelegate {     // provide naviagation to detail screen on cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.userDetails[indexPath.row]
        guard let url = user.htmlUrl else {
            return
        }
        if let detailsVC = Bundle.main.loadNibNamed("GITUserDetailsViewController", owner: nil, options: nil)?.first as? GITUserDetailsViewController {
            detailsVC.gitUrl = url
            guard let navigationController = self.navigationController else {
                return
            }
            navigationController.pushViewController(detailsVC, animated: true)
        }
    }
}


// MARK: SearchBar Delegate Methods
extension GITUsersViewController: UISearchBarDelegate, UITextFieldDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchUsers(_:)), object: searchBar)
        perform(#selector(self.searchUsers(_:)), with: searchBar, afterDelay: 0.75)
    }
    @objc func searchUsers(_ searchBar: UISearchBar) {
        guard viewModel.searchUsers(searchBar.text) == true else {
            return
        }
        searchBar.isLoading = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {       // cancel search
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {      // dismiss keyboard on return button click
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Scrollview Delegate Methods
extension GITUsersViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height )) {       // load more data for pagination
            guard viewModel.loadMoreUsers() == false else {
                return
            }
            paginationIndicator.startAnimating()
        }
    }
}

// MARK: Filter and Sort Methods
extension GITUsersViewController {
    @IBAction func filterTapped(_ sender: Any) {        // show filter options
        sortView.isHidden = true
        filterView.isHidden = !filterView.isHidden
    }
    @IBAction func sortTapped(_ sender: Any) {      // show sort options
        filterView.isHidden = true
        sortView.isHidden = !sortView.isHidden
    }
    @IBAction func applySort(_ sender: UIButton) {      // apply sorting
        if sortButtons[sender.tag].isSelected {     // clicking already selected sort
            sortButtons.forEach{$0.isSelected = false}
            viewModel.sortText  = nil       // deselect sort
        } else {
            sortButtons.forEach{$0.isSelected = false}
            sortButtons[sender.tag].isSelected = !sortButtons[sender.tag].isSelected
            switch sender.tag {
            case 0:
                viewModel.sortText = "followers"        // sorting on the basis of no. of followers
            case 1:
                viewModel.sortText = "repositories"     // sorting on the basis of no. of repositries
            default:
                break
            }
        }
        fetchUpdatedUsers()     // update users list based on sort
    }
    @IBAction func filterValueChanged(_ sender: UISlider) {     // select value for filter options
        switch sender.tag {
        case 0:
            repoValueLabel.text = "\(Int(sender.value)) or more repositries"
        case 1:
            followerValueLabel.text = "\(Int(sender.value)) or more followers"
        default:
            break
        }
    }
    @IBAction func applyFilter(_ sender: UISlider) {        // apply filter
        switch sender.tag {
        case 0:
            viewModel.repoCount = Int(sender.value)     // filter on the basis of repositries count
        case 1:
            viewModel.followersCount = Int(sender.value)        // filter on the basis of followers count
        default:
            break
        }
        fetchUpdatedUsers()     // update users list on the basis of filter value
    }
}
