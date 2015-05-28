//
//  Store.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-05.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class Store: NSObject, NSCoding {
  var name = ""
  var aisles: [Aisle] = []
  var aisleOrder: [String] = []
  var needsSaving = true
  var updateDate: NSDate!
  
  override var description: String {
    var retval = "Store: " + name + "\n"
    for aisle in aisles {
      retval += aisle.description + "\n"
    }
    return retval
  }

  // MARK: - Basic functions
  
  override init() {
    updateDate = NSDate()
    super.init()
  }
  
  init(name: String) {
    updateDate = NSDate()
    self.name = name
    super.init()
  }
  
  init(name: String, aisles: [String]) {
    self.name = name
    self.aisleOrder = aisles
    updateDate = NSDate()
    super.init()
  }
    
  func numberOfAisles() -> Int {
    return aisles.count
  }
  
  func numberOfItemsInAisle(index: Int) -> Int {
    return aisles[index].items.count
  }
  
  // MARK: - Add items to store
  
  func findAisle(name: String) -> Aisle! {
    for aisle in aisles {
      if aisle.name.lowercaseString == name.lowercaseString {
        return aisle
      }
    }
    return nil
  }

  func addAisle(aisleName: String) {
    if findAisle(aisleName) == nil {
      aisleOrder.insert(aisleName, atIndex: aisleOrder.count-1)
      aisles.insert(Aisle(name: aisleName), atIndex: aisles.count-1)
      updateDate = NSDate()
    }
  }
  
  func addItem(item: Item, toAisleNamed: String) {
    if let aisle = findAisle(toAisleNamed) {
      aisle.items.append(item)
    } else {
      addAisle(toAisleNamed)
      if let aisle = findAisle(toAisleNamed) {
        aisle.items.append(item)
      }
    }
  }
  
  func stockAisles(items: [Item], requiredInList: Bool) {
    aisles = []
    for aisleName in aisleOrder {
      aisles.append(Aisle(name: aisleName))
    }
    for item in items {
      if !requiredInList || item.inList {
        addItem(item, toAisleNamed: item.aisleName)
      }
    }
    // if only desplaying listed items, delete empty aisles
    var n = aisles.count-1
    while n >= 0 {
      if aisles[n].items.count == 0 {
        aisles.removeAtIndex(n)
      }
      n--
    }
  }
  
  func stockEverything(items: [Item]) {
    aisles = []
    for aisleName in aisleOrder {
      aisles.append(Aisle(name: aisleName))
    }
    for item in items {
      addItem(item, toAisleNamed: item.aisleName)
    }
  }
  
  func stockAisles(items: [Item], withPrefix: String) {
    aisles = []
    for aisleName in aisleOrder {
      aisles.append(Aisle(name: aisleName))
    }

    for item in items {
      if  count(withPrefix) == 0 || item.name.hasPrefix(withPrefix) {
        addItem(item, toAisleNamed: item.aisleName)
      }
    }
    // delete empty aisles
    var n = aisles.count-1
    while n >= 0 {
      if aisles[n].items.count == 0 {
        aisles.removeAtIndex(n)
      }
      n--
    }
  }
  
// MARK: - NSCoding
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeObject(aisleOrder, forKey: "aisleOrder")
    aCoder.encodeObject(updateDate, forKey: "updateDate")
  }
  
  required init(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObjectForKey("name") as! String
    aisleOrder = aDecoder.decodeObjectForKey("aisleOrder") as! [String]
    updateDate = aDecoder.decodeObjectForKey("updateDate") as! NSDate
    super.init()
  }

  
}
