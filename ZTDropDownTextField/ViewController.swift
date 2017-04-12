//
//  ViewController.swift
//  Example
//
//  Created by Ziyang Tan on 7/30/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension UIViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let simpleDemoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SimpleDemoViewController") as! SimpleDemoViewController
            show(simpleDemoVC, sender: self)
        } else {
            let mapViewDemoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewDemoViewController") as! MapViewDemoViewController
            show(mapViewDemoVC, sender: self)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "mainCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "mainCell")
        }
        
        if indexPath.row == 0 {
            cell!.textLabel!.text = "Simple Demo"
        } else {
            cell!.textLabel!.text = "Map View Demo"
        }
        return cell!
    }
}
