//
//  AisleViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-06.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class AisleViewController: UITableViewController, UITextFieldDelegate, EditAisleViewControllerDelegate {

  var dataModel: DataModel!
  
  func refresh(sender: UIBarButtonItem) {
    dataModel.setupDemo()
    tableView.reloadData()
  }
  
  @IBOutlet weak var inputTextField: UITextField!
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField.text == "demo" {
      dataModel.setupDemo()
      textField.text = ""
      textField.resignFirstResponder()
    } else if count(textField.text) > 0 {
      dataModel.store.addAisle(textField.text)
      textField.text = ""
      dataModel.saveDataModel()
      self.tableView.reloadData()
    } else {
      textField.resignFirstResponder()
    }
    return true
  }
  
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

  
  // MARK: - EditIAisleViewController delegate
  
  func editAisleViewControllerDidCancel(controller: EditAisleViewController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func editAisleViewController(controller: EditAisleViewController, didFinishEditingAisle numToEdit: Int, withText text: String) {
    let oldAisle = dataModel.store.aisleOrder[numToEdit]
    for item in dataModel.allItems {
      if item.aisleName == oldAisle {
        item.aisleName = text
      }
    }
    dataModel.store.aisleOrder[numToEdit] = text
    dismissViewControllerAnimated(true, completion: nil)
    tableView.reloadData()
    dataModel.saveDataModel()
  }
  
  // MARK: - Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "EditAisle" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! EditAisleViewController
      controller.delegate = self
      if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
        controller.numToEdit = indexPath.row
        controller.textToEdit = dataModel.store.aisleOrder[indexPath.row]
      }
    }
  }


    override func viewDidLoad() {
        super.viewDidLoad()
    }

  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.store.aisleOrder.count - 1
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("AisleCell", forIndexPath: indexPath) as! UITableViewCell
    let label = cell.viewWithTag(3000) as! UILabel
    label.text = dataModel.store.aisleOrder[indexPath.row]
    return cell
    }

  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      let aisle = dataModel.store.aisleOrder[indexPath.row]
      for item in dataModel.allItems {
        if item.aisleName == aisle {
          item.aisleName = "Unknown"
        }
      }
      dataModel.store.aisleOrder.removeAtIndex(indexPath.row)
      tableView.reloadData()
      dataModel.sortAllItems()
      dataModel.saveDataModel()
    } else if editingStyle == UITableViewCellEditingStyle.Insert {
      assert(false)
    }
  }
  
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    let aisle = dataModel.store.aisleOrder[sourceIndexPath.row]
    dataModel.store.aisleOrder.removeAtIndex(sourceIndexPath.row)
    dataModel.store.aisleOrder.insert(aisle, atIndex: destinationIndexPath.row)
    dataModel.sortAllItems()
    dataModel.saveDataModel()
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}
