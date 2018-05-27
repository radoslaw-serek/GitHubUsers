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

class ViewController: UIViewController {

    var arrayOfUsers = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    var userService = UserService()
    
    let userLoginCellIdentifier = "userLogin"
    let userDetailsViewIdentifier = "UserDetails"
    
    let manager = NetworkReachabilityManager(host: "www.apple.com")
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        userService.delegate = self
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: userLoginCellIdentifier)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manageConnectionStatusChanges()
        userService.getDataFromUrl()
    }
    
    private func manageConnectionStatusChanges() {
        manager?.listener = { [weak self] status in
            switch status {
            case .notReachable, .unknown:
                self?.presentConnectivityAlert(of: status)
            default: return
            }
        }
    }
    
    private func presentConnectivityAlert(of status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        
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
                userDetailsVC.user = arrayOfUsers[indexPath.row]
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: userLoginCellIdentifier) as? UserListTableViewCell else { return UITableViewCell() }
        let user = arrayOfUsers[indexPath.row]
        cell.userLoginLabel.text = user.login
        cell.avatarImage.af_setImage(withURL: URL(string: user.avatarUrl)!, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: userDetailsViewIdentifier, sender: indexPath)
    }
}

extension ViewController: UserServiceDelegate {
    func userService(_ userService: UserService, didRetrieveData userData: [User]) {
        arrayOfUsers = userData
    }
    
    func userService(_ userService: UserService, didFailWithError error: Error) {
        handleError(error)
    }
    
    
}
