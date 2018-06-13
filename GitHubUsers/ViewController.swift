//
//  ViewController.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 10.05.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

let userLoginCellIdentifier = "userLogin"

class ViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    
    private var userListDataSource: UserListDataSource = GroupingTableViewDataSource()
    
    private let userService = UserService()
    
    private let userDetailsViewIdentifier = "UserDetails"
    
    private let manager = NetworkReachabilityManager(host: "www.apple.com")!
    
    private var isGroupingModeOn = true {
        didSet {
            userListDataSource = isGroupingModeOn ? GroupingTableViewDataSource() : NonGroupingTableViewDataSource()
        }
    }
    
    @IBAction func changeTableViewMode(_ sender: UIBarButtonItem) {
        let tempArrayOfUsers = userListDataSource.retrieveUsers()
        isGroupingModeOn = !isGroupingModeOn
        userListDataSource.setArrayOfUsers(with: tempArrayOfUsers)
        tableView.dataSource = userListDataSource
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = userListDataSource
        userService.delegate = self
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: userLoginCellIdentifier)
        manageConnectionStatusChanges()
        manager.startListening()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !manager.isReachable {
            presentConnectivityAlert(of: .notReachable)
        }
        userService.getDataFromUrl()
    }
    
    private func manageConnectionStatusChanges() {
        manager.listener = { [weak self] status in
            switch status {
            case .notReachable, .unknown:
                self?.presentConnectivityAlert(of: status)
            default:
                self?.errorLabel.isHidden = true
            }
        }
    }
    
    private func presentConnectivityAlert(of status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        errorLabel.text = "Connectivity issue. Status: \(status). Please check."
        errorLabel.isHidden = false
        
    }
    
    fileprivate func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == userDetailsViewIdentifier {
            let userDetailsVC = segue.destination as! UserDetailsViewController
            if let indexPath = sender as? IndexPath {
                userDetailsVC.user = userListDataSource.retrieveUser(with: indexPath)
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: userDetailsViewIdentifier, sender: indexPath)
    }
}

extension ViewController: UserServiceDelegate {
    func userService(_ userService: UserService, didRetrieveData userData: [User]) {
        userListDataSource.setArrayOfUsers(with: userData)
        tableView.reloadData()
    }
    
    func userService(_ userService: UserService, didFailWithError error: Error) {
        handleError(error)
    }
}
