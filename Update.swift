//
//  Update.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-06-08.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class Update: NSObject, NSCoding {
  var type = ""
  var item = ""
  var aisle = ""
  var aisleOrder: [String] = []
  
  override var description: String {
    var s = type + " : "
    s += item + " : "
    s += aisle + " : "
    s += aisleOrder.description + "\n"
    return s
  }
  
  // MARK: - Initialize
  
  init(type: String, item: Item) {
    self.type = type
    self.item = item.name
    self.aisle = item.aisleName
    super.init()
  }

  init(aisleOrder: [String]) {
    self.aisleOrder = aisleOrder
    super.init()
  }
  
  // MARK: - NSCoding
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(type, forKey: "type")
    aCoder.encodeObject(item, forKey: "item")
    aCoder.encodeObject(aisle, forKey: "aisle")
    aCoder.encodeObject(aisleOrder, forKey: "aisleOrder")
  }
  
  required init(coder aDecoder: NSCoder) {
    type = aDecoder.decodeObjectForKey("type") as! String
    item = aDecoder.decodeObjectForKey("item") as! String
    aisle = aDecoder.decodeObjectForKey("aisle") as! String
    aisleOrder = aDecoder.decodeObjectForKey("aisleOrder") as! [String]
    super.init()
  }

}
