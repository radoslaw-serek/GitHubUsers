//
//  ViewController.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 10.05.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var arrayOfLogins = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    let reusableIdentifier = "userLogin"

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://api.github.com/users")
        let urlRequest = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            
            if let error = error {
                self?.handleError(error)
            }
            if let data = data {
                self?.extractLoginFromData(data)
            }
        }
        task.resume()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: reusableIdentifier)
    }
    
    fileprivate func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func extractLoginFromData(_ data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            if let jsonAsArrayOfAny = json as? Array<Any> {
                var arrayOfLogins = [String]()
                for user in jsonAsArrayOfAny {
                    if let userAsDict = user as? [String:Any] {
                        if let userLogin = userAsDict["login"] as? String {
                            arrayOfLogins.append(userLogin)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.arrayOfLogins = arrayOfLogins
                }
            }
        }
    }
    

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfLogins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier) as? UserListTableViewCell else { return UITableViewCell() }
        cell.userLoginLabel.text = arrayOfLogins[indexPath.row]
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
}
