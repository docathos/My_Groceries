//
//  Aisle.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-04.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class Aisle: NSObject {
  var name = ""
  var items: [Item] = []

  override var description: String {
    var retval = "Aisle: " + name + "\n"
    for item in items {
      retval += item.description + "\n"
    }
    return retval
  }

  init(name: String) {
    self.name = name
    super.init()
  }
  
  func addItem(item: Item) {
    items.append(item)
  }


}
