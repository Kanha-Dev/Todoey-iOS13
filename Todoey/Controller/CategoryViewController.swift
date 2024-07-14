//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Kanha Gupta on 14/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    //Initialise Variables
    var categoryArray = [Category]()
    
    //FilePath for the Save Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            
            //Saves to the Database
            self.saveCategory()
            
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
        return categoryArray.count
    }
    
    //Creates Cells for the Table View
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Constant
        let category = categoryArray[indexPath.row]
        
        //Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    
    //Function for clicking the Category Item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //This line is just to confirm that the view is indeed goToResult
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! TodoListViewController
            //Sends the value to the result view
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
        }
    }
    
    
    //MARK: - Core Data Function
    
    //Function for Saving Data
    func saveCategory(){
        do{
            try context.save()
        }catch{
            print("Error while saving Category \(error)")
        }
        
        //Reloads the TableView after saving so the user could see what he actually feed
        tableView.reloadData()
    }
    
    //Function for Loading Data
    func loadCategory(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        //Loading the Data
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("Error while Loading Categories \(error) ")
        }
        tableView.reloadData()
    }
}
