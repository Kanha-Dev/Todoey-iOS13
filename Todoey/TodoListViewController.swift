//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    //Initialise Variables
    var itemArray = [Item]()
    
    //FilePath for the Save Data
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(dataFilePath)
        
        //Loads the data at startup
        loadItems()
    }

    //MARK: - Table View Datasource Methods

    //Required function for Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //Creates Cels for the Table View
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Constant
        let item = itemArray[indexPath.row]
        
        //Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = item.title
        
        //Sets the Tick Mark for the Todo List
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //Function for clicking the Todo List Item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Checks or Unchecks the List Item
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //Saves the Progress
        saveItems()
        //Animation
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Functions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Local Global Variable for UITextField
        var textField = UITextField()
        
        //Pop Up
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //Initialise a new Item
            let newItem = Item()
            newItem.title = textField.text!
            
            //Appends it to the List
            self.itemArray.append(newItem)
            
            //Saves the Progress
            self.saveItems()
        }
        
        //Button in the Pop Up
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new Item"
            
            //Sets the Global Text field equal to the Local one
            textField = alertTextField
        }
        
        //Animation or Creation
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //Function for Saving Data
    func saveItems(){
        //Saving the Stuff in Plist
        //We will create an instance of PListEncoder
        let encoder = PropertyListEncoder()
        do{
            //Encodes the Data
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch{
            print("Error while Encoding Items \(error)")
        }
        
        //Reloads the TableView after saving so the user could see what he actually feed
        self.tableView.reloadData()
    }
    
    //Function for Loading Data
    func loadItems(){
        //Loading the Data
        if let data = try? Data(contentsOf: dataFilePath!){
            //We will create an instance of PListDecoder
            let decoder = PropertyListDecoder()
            do{
                //Decoding to the Type Item
                itemArray = try decoder.decode([Item].self, from: data)
            } catch{
                print("Error while Decoding Items \(error)")
            }
        }
    }
}

