//
//  OptionsViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 23/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //hide separator line
        self.tableView.separatorColor = .clear;
        
        //set cell height
        self.tableView.rowHeight = 80;

    }
}


//MARK: - TableView

extension OptionsViewController: UITableViewDataSource, UITableViewDelegate {

    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        return 1
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        
        //add switch to cell
        let switchObj = UISwitch(frame: CGRect(x: 1, y: 1, width: 20, height: 20))
        switchObj.isOn = false
        switchObj.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
        cell.accessoryView = switchObj
        
        return cell
        
    }
    
    @objc func toggle(_ sender: UISwitch) {
        print("Switched!")
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //will print cell that was tapped on
        //print(indexPath.row)

        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
