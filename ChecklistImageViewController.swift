//
//  ChecklistImageViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-03-24.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class ChecklistImageViewController: UIViewController {

  @IBOutlet weak var itemNamelabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  var item: Item!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.contentMode = .ScaleAspectFit
    
    itemNamelabel.text = item.name
    let image = item.loadImage()
    if let image = image {
      imageView.image = image
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
