//
//  GroupingTableViewDataSource.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 10.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation
import UIKit



class GroupingTableViewDataSource: NSObject, UITableViewDataSource {
    
    var arrayOfUsers = [User]() {
        didSet {
            dictOfUsers = Dictionary(grouping: arrayOfUsers, by: { String($0.login.first!).capitalized })
            arrayOfKeys = Array(dictOfUsers.keys).sorted()
        }
    }
    
    var dictOfUsers = Dictionary<String,[User]>()
    
    var arrayOfKeys = [String]()

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(arrayOfKeys[section]).capitalized
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictOfUsers.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = arrayOfKeys[section]
        return dictOfUsers[key]?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: userLoginCellIdentifier) as? UserListTableViewCell else { return UITableViewCell() }
        let key = arrayOfKeys[indexPath.section]
        guard let user = dictOfUsers[key]?[indexPath.row] else { return UITableViewCell()}
        cell.userLoginLabel.text = user.login
        cell.avatarImage.af_setImage(withURL: URL(string: user.avatarUrl)!, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        return cell
    }
}
