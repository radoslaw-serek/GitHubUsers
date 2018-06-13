//
//  UserListDataSource.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 10.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation
import UIKit

protocol UserListDataSource: UITableViewDataSource {
    func setArrayOfUsers(with array: [User])
    func retrieveUser(with indexPath: IndexPath) -> User
    func retrieveUsers() -> [User]
}

class GroupingTableViewDataSource: NSObject, UserListDataSource {
    
    private var arrayOfUsers = [User]()
    
    private var dictOfUsers = Dictionary<String,[User]>()
    
    private var arrayOfKeys = [String]()

    func setArrayOfUsers(with array: [User]) {
        arrayOfUsers = array
        dictOfUsers = Dictionary(grouping: arrayOfUsers, by: { String($0.login.first!).capitalized })
        arrayOfKeys = Array(dictOfUsers.keys).sorted()
    }
    
    
    func retrieveUser(with indexPath: IndexPath) -> User {
        let key = arrayOfKeys[indexPath.section]
        return dictOfUsers[key]![indexPath.row]
    }
    
    func retrieveUsers() -> [User] {
        return arrayOfUsers
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(arrayOfKeys[section]).capitalized
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictOfUsers.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = arrayOfKeys[section]
        return dictOfUsers[key]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: userLoginCellIdentifier) as? UserListTableViewCell else { return UITableViewCell() }
        let user = retrieveUser(with: indexPath)
        cell.userLoginLabel.text = user.login
        cell.avatarImage.af_setImage(withURL: URL(string: user.avatarUrl)!, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        return cell
    }
}

class NonGroupingTableViewDataSource: NSObject, UserListDataSource {
    
    private var arrayOfUsers = [User]()
    
    func setArrayOfUsers(with array: [User]) {
        arrayOfUsers = array
    }
    
    func retrieveUser(with indexPath: IndexPath) -> User {
        return arrayOfUsers[indexPath.row]
    }

    func retrieveUsers() -> [User] {
        return arrayOfUsers
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: userLoginCellIdentifier) as? UserListTableViewCell else { return UITableViewCell() }
        let user = retrieveUser(with: indexPath)
        cell.userLoginLabel.text = user.login
        cell.avatarImage.af_setImage(withURL: URL(string: user.avatarUrl)!, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        return cell
    }
}
