//
//  ViewController.swift
//  TestProject
//
//  Created by MG on 04.05.2020.
//  Copyright © 2020 MG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

}
