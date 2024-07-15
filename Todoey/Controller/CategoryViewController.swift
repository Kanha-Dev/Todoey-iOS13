//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Kanha Gupta on 15/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    //Initialise Realm
    let realm = try! Realm()
    //Initialise Variables
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the data at startup
        loadCategory()
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Sets up the NavBar
        super.viewWillAppear(animated)
        updateNavBarColor(withHexCode: "36374C")
        tableView.backgroundColor = UIColor(hexString: "000000")
    }
    
    //Hanles the Disappear function for good practice
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateNavBarColor(withHexCode: "36374C")
    }
    
    //Used for UpdatingNavBarColor
    func updateNavBarColor(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        if let navBarColor = UIColor(hexString: colorHexCode) {
            //New Instance
            let appearance = UINavigationBarAppearance()
            //Configure Solid Background
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navBarColor
            appearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            appearance.titleTextAttributes = [.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            
            //Different State Apprearances
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            
            //Properties
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            navBar.isTranslucent = false
        }
    }
    
    
    
    //MARK: - Table View Datasource Methods
    
    //Required function for Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    //Creates Cells for the Table View
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            //Setting the Name and Color of Category
            cell.textLabel?.text = category.name
            guard let categoryColor = UIColor(hexString: category.colour) else {fatalError()}
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
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

    //MARK: - IBActions
    
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
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            
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
    
    //MARK: - Database Functions
    
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
    
    //Function for Deletion of Category
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = categories?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error while deleting category \(error)")
            }
        }
    }
}
