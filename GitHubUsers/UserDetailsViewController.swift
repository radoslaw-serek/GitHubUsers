//
//  UserDetailsViewController.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 11.05.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
    
    var user: User? {
        didSet {
            userUrl?.text = user?.htmlUrl
        }
    }
    
    @IBOutlet weak var userUrl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userUrl?.text = user?.htmlUrl
    }
    
    

}


