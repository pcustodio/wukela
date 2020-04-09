//
//  CatViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 09/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class CatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let categories = ["Sociedade",
                  "Desporto",
                  "Economia",
                  "Política",
                  "Cultura",
                  "Desporto",
                  "Ciência e Tecnologia",
                  "Opinião"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //hide separator line
        //self.tableView.separatorColor = .clear;
        
        //set cell height
        self.tableView.rowHeight = 60;
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()

        //reload table
        tableView.reloadData()
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Tableview
    
    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    //create our cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row]


        return cell
        
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //will print cell that was tapped on
        //print(indexPath.row)

        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
