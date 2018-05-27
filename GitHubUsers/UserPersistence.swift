//
//  UserPersistence.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 13.05.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation

protocol UserPersistence {
    
    func getUsers() -> [User]
    
    func storeUsers(arrayOfUsers: [User])
    
}

class FileUserPersistence: UserPersistence {

    private let userFileName = "UserFile.swift"
    
    private var userFileURL: URL? {
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir?.appendingPathComponent(userFileName)
    }
    
    func getUsers() -> [User] {
        let decoder = JSONDecoder()
        if let url = userFileURL, let data = try? Data.init(contentsOf: url), let arrayOfUsers = try? decoder.decode([User].self, from: data) {
            return arrayOfUsers
        } else {
            return [User]()
        }
    }
    
    func storeUsers(arrayOfUsers: [User]) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(arrayOfUsers), let url = userFileURL {
            do {
                try encodedData.write(to: url)
            } catch {
                print("Couldn't save data to UserFile")
            }
        }
    }
}

class KeyedArchiverUserPersistence: UserPersistence {
    
    private let userFileName = "UserFileArchive.swift"
    
    private var userFilePath: String? {
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir?.appendingPathComponent(userFileName).path
    }
    

    func getUsers() -> [User] {
        let decoder = JSONDecoder()
        if let filePath = userFilePath, let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data, let arrayOfUsers = try? decoder.decode([User].self, from: data) {
            return arrayOfUsers
        } else {
            return [User]()
        }
    }
    
    func storeUsers(arrayOfUsers: [User]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(arrayOfUsers), let filePath = userFilePath {
            let saved = NSKeyedArchiver.archiveRootObject (data, toFile: filePath)
            print("\(saved)")
        }
    }
}
