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
  var aisles: [Aisle] = []
  var undoList: [Item] = []
  
  override var description: String {
    var retval = ""
    for aisle in aisles {
        retval += aisle.description + "\n"
    }
    return retval
  }

  // MARK: - Initialize
  
  override init() {
    aisles.append(Aisle(name: "Unknown"))
    super.init()
  }
  
  // MARK: - find items and aisles
  
  func findAisleNamed(name: String) -> Aisle? {
    for aisle in aisles {
      if name == aisle.name {
        return aisle
      }
    }
    return nil
  }
  
  func findAisleForItem(item: Item) -> Aisle? {
    for aisle in aisles {
      let itemIndex = find(aisle.items, item)
      if let itemIndex = itemIndex {
        return aisle
      }
    }
    return nil
  }
  
  func findItemAndAisle(itemName: String) -> (Item, Aisle)? {
    for aisle in aisles {
      for item in aisle.items {
        if item.name == itemName {
          return (item, aisle)
        }
      }
    }
    return nil
  }
  
  func findItemNamed(name: String) -> Item? {
    if let (item, aisle) = findItemAndAisle(name) {
      return item
    } else {
      return nil
    }
  }
  
  // MARK: - Basic API: add, move, remove items and aisles
  
  func addNewAisleNamed(name: String) {
    assert (aisles.last?.name == "Unknown")
    let aisle = Aisle(name: name)
    aisles.insert(aisle, atIndex: aisles.count - 1)
  }
  
  func removeAisleNamed(name: String) {
    let aisle = findAisleNamed(name)!
    aisles.removeAtIndex(find(aisles, aisle)!)
  }
  
  func addNewItemNamed(itemName: String, toAisleNamed aisleName: String) {
    var aisle = findAisleNamed(aisleName)
    if aisle == nil {
      aisle = Aisle(name: aisleName)
      aisles.append(aisle!)
    }
    aisle!.items.append(Item(name: itemName))
  }
  
  func addNewItemNamed(name: String) {
    addNewItemNamed(name, toAisleNamed: "Unknown")
  }
  
  func removeItemNamed(name: String) {
    let (item, aisle) = findItemAndAisle(name)!
    aisle.items.removeAtIndex(find(aisle.items, item)!)
  }
  
  func moveItem(item: Item, toAisle aisle: Aisle) {
    if let oldAisle = findAisleForItem(item) {
      if let itemIndex = find(oldAisle.items, item) {
        oldAisle.items.removeAtIndex(itemIndex)
        aisle.items.append(item)
      } else {
        assert(false)
      }
    } else {
      assert(false)
    }
  }
  
  func moveItemNamed(itemName: String, toAisleNamed aisleName: String) {
    if let item = findItemNamed(itemName) {
      if let newAisle = findAisleNamed(aisleName) {
        moveItem(item, toAisle: newAisle)
      } else {
        assert(false)
      }
    } else {
      assert(false)
    }
  }
  
  func renameItem(item: Item, toName newName: String) {
    item.name = newName
  }
  
  func renameItemNamed(oldName: String, toName newName: String) {
    if let item = findItemNamed(oldName) {
      renameItem(item, toName: newName)
    }
    else {
      assert(false)
    }
  }
  
  func renameAisle(aisle: Aisle, toName newName: String) {
    aisle.name = newName
  }
  
  func renameAisleNamed(oldName: String, toName newName: String) {
    if let aisle = findAisleNamed(oldName) {
      renameAisle(aisle, toName: newName)
    } else {
      assert(false)
    }
  }
  
  func moveAisle(aisle: Aisle, toIndex newIndex: Int) {
    assert(newIndex < aisles.count)
    let aisleIndex = find(aisles, aisle)
    assert(aisleIndex != nil)
    aisles.removeAtIndex(aisleIndex!)
    aisles.insert(aisle, atIndex: newIndex)
  }
  
  func moveAisleNamed(name: String, toIndex newIndex: Int) {
    if let aisle = findAisleNamed(name) {
      moveAisle(aisle, toIndex: newIndex)
    } else {
      assert(false)
    }
  }
  
  func addToUndoItemNamed(name: String) {
    undoList.append(findItemNamed(name)!)
  }
  
  // returns item and aisle names
  // TODO: what if undo, then remove that item??
  func undo() -> (String, String)? {
    if undoList.count == 0 {
      return nil
    } else {
      let item = undoList.removeLast()
      item.inList = true
      let aisle = findAisleForItem(item)!
      //      addUpdate("addToList", item: item)
      return (item.name, aisle.name)
    }
  }
  
  // MARK: - tableview related

  func numberOfAisles() -> Int {
    return aisles.count
  }
  
  func numberOfItemsInAisleIndexed(index: Int) -> Int {
    return aisles[index].items.count
  }
  
  // second return value is whether item is only item in section
  func getIndexpathForItemNamed(name: String) -> (NSIndexPath, Bool) {
    let (item, aisle) = findItemAndAisle(name)!
    let section = find(aisles, aisle)!
    let row = find(aisle.items, item)!
    let indexPath = NSIndexPath(forRow: row, inSection: section)
    if aisle.items.count == 1 {
      return (indexPath, true)
    } else {
        return (indexPath, false)
    }
  }

  // MARK: - Debug related
  
  func setupDemo() {
    println("Reset to Demo!")
    aisles = [Aisle(name: "Unknown")]
    undoList = []
    addNewItemNamed("apples", toAisleNamed: "Fruit")
    addNewItemNamed("bananas", toAisleNamed: "Fruit")
    addNewItemNamed("cheddar", toAisleNamed: "Cheese")
    addNewItemNamed("feta", toAisleNamed: "Cheese")
    addNewItemNamed("blue", toAisleNamed: "Cheese")
    saveDataModel()
    print(description)
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
    archiver.encodeObject(aisles, forKey: "aisles")
    archiver.finishEncoding()
    data.writeToFile(dataFilePath(), atomically: true)
  }

  func loadDataModel() {
    let path = dataFilePath()
    if NSFileManager.defaultManager().fileExistsAtPath(path) {
      if let data=NSData(contentsOfFile: path) {
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        aisles = unarchiver.decodeObjectForKey("aisles") as! [Aisle]
        unarchiver.finishDecoding()
      }
    }
  }
  
  // MARK: - CloudKit

  /*
  func addUpdate(type: String, item: Item) {
  sharingModel.updateList.append(Update(type: type, item: item))
  }
  */
  
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

   
 