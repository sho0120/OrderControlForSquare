//
//  PreViewController.swift
//  Order Control for Square
//
//  Created by 李昌 on 2020/11/04.
//  Copyright © 2020 李昌. All rights reserved.
//

import Foundation
import UIKit


//function:select, add, delete
class MemberController: UIViewController{
    var whoIsInShift: [String] = []
    
    var toolbar: UIToolbar?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "今日のスタッフは？"
        
        let scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        for staff in self.whoIsInShift{
            //let button = staffNameButton(frame: CGRect(x: y: ))
        }
    }
}


class staffNameButton: UIButton{
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, name: String) {
        super.init(frame: frame)
        self.setTitle(name, for: [])
        self.layer.cornerRadius = 2.0
        self.setTitleColor(UIColor.white, for: [])
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.blue.cgColor
    }
    
    override func layoutSubviews() {
        self.titleLabel?.numberOfLines = 1
    }
}
