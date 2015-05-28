//
//  ChecklistViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-04.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController {
  var dataModel: DataModel!
  
  @IBOutlet weak var undoButton: UIBarButtonItem!
  
  func setUndoButton() {
    if let dataModel = dataModel {
      if dataModel.undoList.count == 0 {
        undoButton.enabled = false
      } else {
        undoButton.enabled = true
      }
    }
  }
  
  @IBAction func undo(sender: AnyObject) {
    if let item = dataModel.undo() {
      dataModel.stockAislesFromChecklist()
      let (indexPath, needSection) = dataModel.getIndexpathFor(item)
      if let indexPath = indexPath {
        tableView.beginUpdates()
        if (needSection) {
          let indexSet = NSIndexSet(index: indexPath.section)
          tableView.insertSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
      }
    }
    setUndoButton()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataModel.stockAislesFromChecklist()
    tableView.rowHeight = 44
    self.title = dataModel.store.name
    setUndoButton()
    
//    tableView.backgroundColor = UIColor.grayColor()
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
   
  // MARK: - Table view functions
  
  func configureCell(cell:UITableViewCell, withItem item: Item) {
      let label = cell.viewWithTag(1000) as! UILabel
      label.text = item.name
      if item.imageFileName != nil {
        cell.accessoryType = UITableViewCellAccessoryType.DetailButton
      } else {
        cell.accessoryType = UITableViewCellAccessoryType.None
      }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return dataModel.store.numberOfAisles()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.store.numberOfItemsInAisle(section)
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return dataModel.store.aisles[section].name
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! UITableViewCell
    let aisle = dataModel.store.aisles[indexPath.section]
    let item = aisle.items[indexPath.row]
    configureCell(cell, withItem: item)
    cell.backgroundColor = UIColor.clearColor()
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      let aisle = dataModel.store.aisles[indexPath.section]
      let item = aisle.items[indexPath.row]
      item.toggleInList()
      dataModel.addToUndo(item)
      setUndoButton()
      aisle.items.removeAtIndex(indexPath.row)
      let indexPaths = [indexPath]
      tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
      if aisle.items.count == 0 {
        dataModel.store.aisles.removeAtIndex(indexPath.section)
        var indexSet = NSIndexSet(index: indexPath.section)
        tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
      }
      dataModel.saveDataModel()
    }
  }
  

  
  // MARK: - Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "checklistImage" {
      let controller = segue.destinationViewController as! ChecklistImageViewController
      if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
        let item = dataModel.store.aisles[indexPath.section].items[indexPath.row]
        controller.item = item
      }
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  
}
