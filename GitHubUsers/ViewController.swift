//
//  ViewController.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 10.05.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var arrayOfUsers = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var imageCache = NSCache<NSString, UIImage>() {
        didSet {
            tableView.reloadData()
        }
    }
    let userLoginCellIdentifier = "userLogin"
    let userDetailsViewIdentifier = "UserDetails"
    
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
                self?.extractJsonFromData(data)
            }
        }
        task.resume()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: userLoginCellIdentifier)
//        tableView.register(UINib(nibName: "UserDetailsViewController", bundle: Bundle.main), forCellReuseIdentifier: userDetailsViewIdentifier)
        
        
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 120
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//    super.viewDidAppear(animated)
//        tableView.reloadData()
//    }
    
    fileprivate func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func extractJsonFromData(_ data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            if let jsonAsArrayOfAny = json as? Array<Any> {
                var arrayOfUsers = [User]()
                for user in jsonAsArrayOfAny {
                    if let userAsDict = user as? Json {
                        let user = User(with: userAsDict)
                            arrayOfUsers.append(user)
                    }
                }
                DispatchQueue.main.async {
                    self.arrayOfUsers = arrayOfUsers
                }
            }
        }
    }
    
    fileprivate func fetchImage(from urlString: String, completion: @escaping ((UIImage) -> Void)) {
        if let url = URL(string: urlString) {
            if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
                completion(cachedImage)
            } else {
                let request = URLRequest(url: url)
                let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                    if let error = error {
                        self?.handleError(error)
                    }
                    if let data = data, let image = UIImage(data: data) {
                        self?.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == userDetailsViewIdentifier {
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
        //cell.urlLabel.text = user.htmlUrl
        fetchImage(from: user.avatarUrl) { image in
            let avatarImage = cell.avatarImage
                avatarImage?.image = image
        }
        tableView.rowHeight = 60
        return cell
    }
    
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: userDetailsViewIdentifier, sender: indexPath)

    }
    
}

extension ViewController: UITableViewDelegate {
    
}
