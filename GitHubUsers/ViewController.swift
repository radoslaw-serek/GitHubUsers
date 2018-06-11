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


//    private enum dataSource {
//        case grouping (GroupingTableViewDataSource) = 
//        case nonGrouping (NonGroupingTableViewDataSource)
//    }
    
    private var groupingTableViewDataSource: GroupingTableViewDataSource?

    private var nonGroupingTableViewDataSource: NonGroupingTableViewDataSource?
    
    private var userService = UserService()
    
    private let userDetailsViewIdentifier = "UserDetails"
    
    private let manager = NetworkReachabilityManager(host: "www.apple.com")
    
    private var isGroupingModeOn = false
    
    private func setTableViewMode() {
        if isGroupingModeOn {
            groupingTableViewDataSource = GroupingTableViewDataSource()
            nonGroupingTableViewDataSource = nil
            tableView.dataSource = groupingTableViewDataSource
        } else {
            groupingTableViewDataSource = nil
            nonGroupingTableViewDataSource = NonGroupingTableViewDataSource()
            tableView.dataSource = nonGroupingTableViewDataSource
        }
    }
    
    @IBAction func changeTableViewMode(_ sender: UIBarButtonItem) {
        isGroupingModeOn = !isGroupingModeOn
        userService.getDataFromUrl()
        setTableViewMode()
        tableView.reloadData()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        setTableViewMode()
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
        let size = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30)
        let label = UILabel(frame: size)
        label.text = "Connectivity issue. Status: \(status). Please check."
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.red
        self.view.addSubview(label)
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
                if isGroupingModeOn, let key = groupingTableViewDataSource?.arrayOfKeys[indexPath.section] {
                    userDetailsVC.user = groupingTableViewDataSource?.dictOfUsers[key]![indexPath.row]
                } else {
                    userDetailsVC.user = nonGroupingTableViewDataSource?.arrayOfUsers[indexPath.row]
                }
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
        if isGroupingModeOn {
            groupingTableViewDataSource?.arrayOfUsers = userData
        } else {
            nonGroupingTableViewDataSource?.arrayOfUsers = userData
        }
        tableView.reloadData()
    }
    
    func userService(_ userService: UserService, didFailWithError error: Error) {
        handleError(error)
    }
    
    
}
