//
//  DataModel.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-06.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit
import CloudKit
import MobileCoreServices

class DataModel: NSObject {
  var allItems: [Item] = []
  var store: Store!
  var lastCloudSync: NSDate!
  var undoList: [Item] = []
  let MaxUndoListSize = 1000
  var sharingModel: SharingModel!
  
  override var description: String {
    var retval = ""
    for item in allItems {
        retval += item.description + "\n"
    }
    return retval
  }

  // MARK: - Initialize
  
  override init() {
    store = Store()
    sharingModel = SharingModel()
    super.init()
  }
  
  // MARK: - helper functions

  func getIndexpathFor(item: Item) -> (NSIndexPath?, Bool) {
    let aisle = store.findAisle(item.aisleName)
    if let aisle = aisle {
      var section = find(store.aisles, aisle)
      if let section = section {
        let row = find(aisle.items, item)
        if let row = row {
          let indexPath = NSIndexPath(forRow: row, inSection: section)
          if aisle.items.count == 1 {
            return (indexPath, true)
          } else {
            return (indexPath, false)
          }
        }
      }
    }
    return (nil, false)
  }
  
  func setupDemo() {
    println("Reset to Demo!")
    allItems = []
    undoList = []
    sharingModel = SharingModel()
    lastCloudSync = nil
    let aisleNames = ["Fruit", "Cheese", "Unknown"]
    store = Store(name: "Groceries", aisles: aisleNames)
    addItem("apples", toAisle: "Fruit")
    addItem("bananas", toAisle: "Fruit")
    addItem("cheddar", toAisle: "Cheese")
    addItem("feta", toAisle: "Cheese")
    addItem("blue", toAisle: "Cheese")
    sortAllItems()
    saveDataModel()
    stockAislesFromChecklist()
    print(description)
  }
  
  // MARK: - Undo
  
  func addToUndo(item: Item) {
    undoList.append(item)
    if undoList.count > MaxUndoListSize {
      undoList.removeAtIndex(0)
    }
  }
  
  func undo() -> Item? {
    if undoList.count > 0 {
      let item = undoList.removeLast()
      item.inList = true
      addUpdate("addToList", item: item)
      item.updateDate = NSDate()
      return item
    } else {
      return nil
    }
  }

  // MARK: - Updates
  
  func addUpdate(type: String, item: Item) {
    sharingModel.updateList.append(Update(type: type, item: item))
  }
  // MARK: - Items and aisles
  
  func findItem(name: String) -> Int? {
    if allItems.count == 0 {
      return nil
    }
    for n in 0...allItems.count-1 {
      if allItems[n].name.lowercaseString == name.lowercaseString {
        return n
      }
    }
    return nil
  }
  
  func addItem(name: String, toAisle: String) {
    if findItem(name) == nil {
      allItems.append(Item(name: name, aisleName: toAisle, inList: true))
    } else {
        assert(findItem(name) == nil)
    }
  }
  
  func addItem(name: String) {
    let index = findItem(name)
    if let index = index {
      allItems[index].inList = true
    } else {
      addItem(name, toAisle: "Unknown")
    }
  }

  func deleteItem(name: String, fromAisle: String) {
    for n in 0...allItems.count {
      if allItems[n].name == name && allItems[n].aisleName == fromAisle {
        let itemToDelete = allItems[n]
        let undoIdx = find(undoList, itemToDelete)
        if let undoIdx = undoIdx {
          undoList.removeAtIndex(undoIdx)
        }
        allItems.removeAtIndex(n)
        break
      }
    }
  }
  
  // sort by store.aisleOrder
  func sortAllItems() {
    var newItems: [Item] = []
    for aisle in store.aisleOrder {
      for item in allItems {
        if item.aisleName == aisle {
          newItems.append(item)
        }
      }
    }
    allItems = newItems
  }
  
  func stockAislesFromAllItems() {
    store.stockAisles(allItems, requiredInList: false)
  }
  
  func stockAislesFromChecklist() {
    store.stockAisles(allItems, requiredInList: true)

  }
  
  func stockAislesWithPrefix(prefix: String) {
    store.stockAisles(allItems, withPrefix: prefix)
  }
  func stockEverything() {
    store.stockEverything(allItems)
  }

  // MARK: - NSCoder
  
  func documentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
    return paths[0]
  }
  
  func dataFilePath() -> String {
    return documentsDirectory().stringByAppendingPathComponent("ShoppingList.plist")
  }
  
  func saveDataModel() {
    let data=NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
    archiver.encodeObject(lastCloudSync, forKey: "lastCloudSync")
    archiver.encodeObject(allItems, forKey: "allItems")
    archiver.encodeObject(store, forKey: "store")
    archiver.encodeObject(sharingModel, forKey: "sharingModel")
    archiver.finishEncoding()
    data.writeToFile(dataFilePath(), atomically: true)
  }

  func loadDataModel() {
    let path = dataFilePath()
    if NSFileManager.defaultManager().fileExistsAtPath(path) {
      if let data=NSData(contentsOfFile: path) {
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        lastCloudSync = unarchiver.decodeObjectForKey("lastCloudSync") as! NSDate!
        allItems = unarchiver.decodeObjectForKey("allItems") as! [Item]
        store = unarchiver.decodeObjectForKey("store") as! Store
        sharingModel = unarchiver.decodeObjectForKey("sharingModel") as! SharingModel
        unarchiver.finishDecoding()
      }
    }
  }
  
  // MARK: - CloudKit
/*
  func downloadOperation() -> CKQueryOperation {
    var predicate: NSPredicate!
    NSLog("Downloading!")
    if let lastCloudSync = lastCloudSync {
      predicate = NSPredicate(format: "modificationDate > %@", lastCloudSync)
    } else {
      predicate = NSPredicate(value: true)
    }
    let query = CKQuery(recordType: "Item", predicate: predicate)
    let queryOperation = CKQueryOperation(query: query)
    queryOperation.recordFetchedBlock = { record in
      let newItem = Item(name: (record))
      var foundNewItem = false
      for (index, searchItem) in enumerate(self.allItems) {
        if searchItem.recordID == record.recordID {
          foundNewItem = true
          if self.dateCompare(searchItem.updateDate, isLessThan: newItem.updateDate) {
            self.allItems[index] = newItem
            NSLog("CK Down modified \(newItem)")
          }
          break
        }
      }
      if !foundNewItem {
        self.allItems.append(newItem)
        NSLog("CK Down added \(newItem)")
      }
    }
    queryOperation.queryCompletionBlock = {cursor, error in
      if let cursor = cursor {
        NSLog("ERROR CK download: cursor != nil")
      }
      if let error = error {
        NSLog("ERROR CK download: error = \(error.localizedDescription)")
      }
    }
    queryOperation.completionBlock = { self.lastCloudSync = NSDate() }
    return(queryOperation)
  }
  
  func uploadNewItems() -> CKModifyRecordsOperation {
    NSLog("Uploading new items!")
    var recordsToUpload: [CKRecord] = []
    for (index, update) in enumerate(updateList) {
      if update.recordID == nil {
        recordsToUpload.append(update.item.makeRecord())
        updateList.removeAtIndex(index)
      }
    }
    let saveRecordsOperation = CKModifyRecordsOperation()
    saveRecordsOperation.recordsToSave = recordsToUpload
    saveRecordsOperation.savePolicy = .IfServerRecordUnchanged
    saveRecordsOperation.perRecordCompletionBlock = { record, error in
      let itemName = record.objectForKey("name") as! String
      NSLog("CK Up \(itemName)")
      if let error = error {
        NSLog("ERROR CK upload error = \(error.localizedDescription) for record \(record)!!")
      }
    }
    saveRecordsOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
      if let error = error {
        NSLog("ERROR  CK upload error = \(error.localizedDescription) overall!!")
      } else {
        self.lastCloudSync = NSDate()
      }
    }
    return(saveRecordsOperation)
  }
  
  // redo this to use update list!!
  
  func modifyItemsOperation() -> CKModifyRecordsOperation {
    NSLog("Modifying!")
    var recordIDsToModify: [CKRecordID] = []
    for update in updateList {
      recordIDsToModify.append(update.recordID)
    }
    
    let modifyRecordsOperation = CKModifyRecordsOperation()

    
//    modifyRecordsOperation.recordsToSave = ???

    
    modifyRecordsOperation.savePolicy = .IfServerRecordUnchanged
    modifyRecordsOperation.perRecordCompletionBlock = { record, error in
      let itemName = record.objectForKey("name") as! String
      NSLog("CK Up \(itemName)")
      if let error = error {
        NSLog("ERROR CK upload error = \(error.localizedDescription) for record \(record)!!")
      }
    }
    modifyRecordsOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
      if let error = error {
        NSLog("ERROR  CK upload error = \(error.localizedDescription) overall!!")
      } else {
        self.lastCloudSync = NSDate()
      }
    }
    return(modifyRecordsOperation)
  }

  func syncWithCloud() {
    println("Last sync: \(lastCloudSync)")
    publicDatabase?.addOperation(downloadOperation())
    publicDatabase?.addOperation(uploadNewItems())
    publicDatabase?.addOperation(modifyItemsOperation())
    saveDataModel()
  }
  
  
  func dateCompare(date: NSDate, isLessThan: NSDate) -> Bool {
    if date.compare(isLessThan) == NSComparisonResult.OrderedAscending {
      return true
    } else {
      return false
    }
  }
  */
  
}

   
 