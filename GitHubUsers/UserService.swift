//
//  UserService.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 12.05.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation

protocol UserServiceDelegate: class {
    func userService( _ userService: UserService, didRetrieveData userData: [User])
    func userService(_ userService: UserService, didFailWithError: Error)
}

class UserService {
    
    private let userPersistence: UserPersistence = FileUserPersistence()
    
    private let urlString = "https://api.github.com/users"
    weak var delegate: UserServiceDelegate?
    
    private func extractJsonFromData(_ data: Data) {
        let decoder = JSONDecoder()
        if let arrayOfUsers = try? decoder.decode([User].self, from: data) {
            userPersistence.storeUsers(arrayOfUsers: arrayOfUsers)
            DispatchQueue.main.async {
                self.delegate?.userService(self, didRetrieveData: arrayOfUsers)
            }
        }
    }
    
    func getDataFromUrl() {
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            if let error = error  {
                if let arrayOfUsers = self?.userPersistence.getUsers() {
                    DispatchQueue.main.async {
                        self?.delegate?.userService(self!, didRetrieveData: arrayOfUsers)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.delegate?.userService(self!, didFailWithError: error)
                    }
                }
            }
            if let data = data {
                self?.extractJsonFromData(data)
            }
        }
        task.resume()
    }
    

}


