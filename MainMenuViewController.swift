//
//  MainMenuViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-03-23.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class MainMenuViewController: UITableViewController {

  var dataModel: DataModel!
  
  @IBAction func syncButtonPressed(sender: UIBarButtonItem) {
    if let dataModel = dataModel {
//      dataModel.syncWithCloud()
    }
  }
  
  
  @IBAction func demoButtonPressed(sender: UIBarButtonItem) {
    dataModel.setupDemo()
  }
  
  // MARK: - Initialize
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if dataModel == nil {
      dataModel = DataModel()
      dataModel.loadDataModel()
      if dataModel.allItems.count == 0 {
        dataModel.setupDemo()
      }
    }
    
    for item in dataModel.allItems {
      println(item)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  // MARK: - Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "Checklist" {
      let controller = segue.destinationViewController as! ChecklistViewController
      controller.dataModel = dataModel
    } else if segue.identifier == "AllItems" {
      let controller = segue.destinationViewController as! AllItemsViewController
      controller.dataModel = dataModel
    } else if segue.identifier == "Aisles" {
      let controller = segue.destinationViewController as! AisleViewController
      controller.dataModel = dataModel
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
 
}
