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
  
  // MARK: - helper
  
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
  
  // MARK: - Model functions
  
  func addNewItemNamed(name: String) {
    var aisle = findAisle("Unknown")
    if aisle == nil {
      aisle = Aisle(name: "Unknown")
      aisles.append(aisle!)
    }
    aisle!.items.append(Item(name: name))
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
    if let item = findItem(itemName) {
      if let newAisle = findAisle(aisleName) {
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
    if let item = findItem(oldName) {
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
    if let aisle = findAisle(oldName) {
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
    if let aisle = findAisle(name) {
      moveAisle(aisle, toIndex: newIndex)
    } else {
      assert(false)
    }
  }
  
  
  
  
  // MARK: - tableview related

  func getIndexpathFor(item: Item) -> (NSIndexPath?, Bool) {
    let section = find(aisles, item.aisle)
    let row = find(item.aisle.items, item)
        if let row = row {
          let indexPath = NSIndexPath(forRow: row, inSection: section!)
          if item.aisle.items.count == 1 {
            return (indexPath, true)
          } else {
            return (indexPath, false)
          }
        }
    return (nil, false)
  }
  
  func setupDemo() {
    println("Reset to Demo!")
    items = []
    undoList = []
    aisles = []
    aisles.insert(Aisle(name: "Fruit"), atIndex: 0)
    aisles.insert(Aisle(name: "Cheese"), atIndex: 1)

    addItem("apples", toAisle: "Fruit")
    addItem("bananas", toAisle: "Fruit")
    addItem("cheddar", toAisle: "Cheese")
    addItem("feta", toAisle: "Cheese")
    addItem("blue", toAisle: "Cheese")
//    sortAllItems()
    saveDataModel()
//    stockAislesFromChecklist()
    print(description)
  }
  
  // MARK: - Undo
  
  func addToUndo(item: Item) {
    undoList.append(item)
  }
  
  func undo() -> Item? {
    if undoList.count > 0 {
      let item = undoList.removeLast()
      item.inList = true
      addUpdate("addToList", item: item)
      return item
    } else {
      return nil
    }
  }

  // MARK: - Updates
 /*
  func addUpdate(type: String, item: Item) {
    sharingModel.updateList.append(Update(type: type, item: item))
  }
*/
  
  // MARK: - Items and aisles
  
  func findItem(name: String) -> Item? {
    for item in items {
      if item.name.lowercaseString == name.lowercaseString {
        return item
      }
    }
    return nil
  }

  func findAisle(name: String) -> Aisle? {
    for aisle in aisles {
      if aisle.name.lowercaseString == name.lowercaseString {
        return aisle
      }
    }
    return nil
  }
  
  func addItem(item: Item, toAisle aisle: Aisle) {
    item.aisle = aisle
    aisle.items.append(item)
  }
  
  func addItem(name: String, toAisleNamed aisleName: String) {
    let item = findItem(name)
    let newAisle = findAisle(aisleName)
    assert((item != nil) && (newAisle != nil))
    REMOVE ITEM FROM item?.aisle
    item!.aisle = newAisle
    newAisle!.items.append(item!)
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

   
 