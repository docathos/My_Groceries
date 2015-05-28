//
//  AllItemsViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-05.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class AllItemsViewController: UITableViewController, UITextFieldDelegate, ItemDetailViewControllerDelegate {

  var dataModel: DataModel!

  // MARK: - Textfield
  
  @IBOutlet weak var inputTextField: UITextField!
  
  @IBAction func inputEditingChanged(sender: UITextField) {
    dataModel.stockAislesWithPrefix(inputTextField.text)
    dataModel.saveDataModel()
    self.tableView.reloadData()
  }
  
  @IBAction func inputEditingDidEnd(sender: UITextField) {
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if count(textField.text) > 0 {
      dataModel.addItem(textField.text)
      textField.text = ""
      dataModel.stockEverything()
      dataModel.saveDataModel()
      self.tableView.reloadData()
    } else {
      textField.resignFirstResponder()
    }
    return true
  }

  // MARK: - Move items
  
  @IBAction func editTableView(sender: UIBarButtonItem) {
    if tableView.editing {
      tableView.setEditing(false, animated: true)
      sender.style = UIBarButtonItemStyle.Plain
      sender.title = "Move"
    } else {
      tableView.setEditing(true, animated: true)
      sender.style = UIBarButtonItemStyle.Done
      sender.title = "Done"
    }
  }
  
  // MARK: - Startup
  
  override func viewDidLoad() {
    tableView.rowHeight = 44
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    dataModel.stockEverything()
//    self.tableView.reloadData()
  }

  
  // MARK: - ItemDetailViewController delegate
  
  func itemDetailViewControllerDidCancel(controller: ItemDetailViewController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem itemToEdit: Item) {
    itemToEdit.updateDate = NSDate()
    dismissViewControllerAnimated(true, completion: nil)
    tableView.reloadData() // need to at least update the cell that was edited
    dataModel.saveDataModel()
  }
  
  
  // MARK: - Table view data source / delegate
  
  func configureTextForCell(cell:UITableViewCell, withItem item: Item) {
      let label = cell.viewWithTag(2000) as! UILabel
      label.text = item.name
  }
  func configureCheckmarkForCell(cell:UITableViewCell, withItem item: Item) {
    let label = cell.viewWithTag(2001) as! UILabel
    label.textColor = view.tintColor
    if item.inList {
      label.text = "√"
    } else {
      label.text = ""
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return dataModel.store.aisles.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.store.aisles[section].items.count
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return dataModel.store.aisles[section].name
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let aisle = dataModel.store.aisles[indexPath.section]
    let cell = tableView.dequeueReusableCellWithIdentifier("AllItemsCell", forIndexPath: indexPath) as! UITableViewCell
    let item = aisle.items[indexPath.row]
    configureTextForCell(cell, withItem: item)
    configureCheckmarkForCell(cell, withItem: item)
    return cell
    
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      let aisle = dataModel.store.aisles[indexPath.section]
      let item = aisle.items[indexPath.row]
      item.toggleInList()
      configureCheckmarkForCell(cell, withItem: item)
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      inputTextField.text = ""
      dataModel.stockEverything()
      self.tableView.reloadData()
      dataModel.saveDataModel()
    }
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      let item = dataModel.store.aisles[indexPath.section].items[indexPath.row]
      item.deleteImage()
      dataModel.deleteItem(item.name, fromAisle: item.aisleName)
      dataModel.stockEverything()
      dataModel.saveDataModel()
      tableView.reloadData()
    } else if editingStyle == UITableViewCellEditingStyle.Insert {
      assert(false)
    }
  }
  
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    let sourceAisle = dataModel.store.aisles[sourceIndexPath.section]
    let destAisle = dataModel.store.aisles[destinationIndexPath.section]
    let item = sourceAisle.items[sourceIndexPath.row]
    item.aisleName = dataModel.store.aisleOrder[destinationIndexPath.section]
    item.updateDate = NSDate()
    sourceAisle.items.removeAtIndex(sourceIndexPath.row)
    destAisle.items.insert(item, atIndex: destinationIndexPath.row)
    dataModel.allItems = []
    for aisle in dataModel.store.aisles {
      for item in aisle.items {
        dataModel.allItems.append(item)
      }
    }
    dataModel.stockEverything()
    dataModel.saveDataModel()
  }
  
  // MARK: - Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "EditItem" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! ItemDetailViewController
      controller.delegate = self
      if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
        let item = dataModel.store.aisles[indexPath.section].items[indexPath.row]
        controller.itemToEdit = item
      }
    }
  }
 
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  
}
