//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Kanha Gupta on 14/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    //Initialise Realm
    let realm = try! Realm()
    //Initialise Variables
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the data at startup
        loadCategory()

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Local Global Variable for UITextField
        var textField = UITextField()
        
        //Pop Up
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        //Button in the Pop Up
        let action = UIAlertAction(title: "Add Category", style: .default){ action in
            
            //Initialise a New Category
            let newCategory = Category()
            newCategory.name = textField.text!
            
            
            //Saves to the Database
            self.saveCategory(category: newCategory)
            
        }
        
        //Text Field in Pop Up
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create a new Category"
            textField = alertTextField
        }
        
        //Creating Pop Up
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Table View Datasource Methods
    
    //Required function for Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    //Creates Cells for the Table View
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    
    //Function for clicking the Category Item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Prepare for TodoListViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //This line is just to confirm that the view is indeed goToResult
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! TodoListViewController
            //Sends the value to the result view
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
    
    //MARK: - Core Data Function
    
    //Function for Saving Data
    func saveCategory(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error while saving Category \(error)")
        }
        
        //Reloads the TableView after saving so the user could see what he actually feed
        tableView.reloadData()
    }
    
    //Function for Loading Data
    func loadCategory(){
        //Loading the Data
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
}
