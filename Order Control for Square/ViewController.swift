//
//  ViewController.swift
//  Order Control for Square
//
//  Created by 李昌 on 2020/04/23.
//  Copyright © 2020 李昌. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    //https transition
    //test
    var parameters: [String: Any] = [
        "location_ids": [
            "YOUR ID"
        ],
        "query": [
            "filter": [
                "date_time_filter": [
                    "created_at": [
                        "start_at": "2019-11-24T11:30:00+09:00",
                        "end_at": "2019-11-24T12:00:00+09:00"
                    ]
                ]
            ]
        ]
    ]
    
    private let headers: HTTPHeaders = [
        "Square-Version": "2020-08-26",
        "Authorization": "Bearer YOUR TOKEN",
        "Content-Type": "application/json"
    ]
    
    //for updating order
    var time: String!
    let formatter = ISO8601DateFormatter()
    
    //navigation controller
    var addBtn: UIBarButtonItem!
    var seeStock: UIBarButtonItem!
    
    //from json responce by alamofire
    private var orders: Response?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        
        self.title = "Home"
        //add buttons to navigationbar
        addBtn = UIBarButtonItem(title: "スタッフ", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.editMember))
        self.navigationItem.leftBarButtonItem = addBtn
        seeStock = UIBarButtonItem(title: "後続のオーダー >", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.seeOrderStock))
        self.navigationItem.rightBarButtonItem = seeStock
        self.view.addSubview(self.navigationController!.navigationBar)
        
        self.time = formatter.string(from: Date())
        //put buttons
        let buttonNumber = 8
        let screenSize: CGSize = UIScreen.main.bounds.size
        let width = screenSize.width
        let height = screenSize.height
        let upper = height * 0.05
        let lower = height * 0.55
        let wideSpace = width * 0.25
        let viewHeight = height * 0.4
        let viewWidth = width * 0.2
        let fromWideSpace = width * 0.025
        
        
        //self.navigationController?.navigationBar.frame = CGRect(x:0, y:0, width: width, height: 60)
        //self.navigationController?.navigationBar.isHidden = false
        
        for i in 0..<buttonNumber{
            if(i%2 == 0){
                let orderButton = OrderSheet(frame: CGRect(x: wideSpace * CGFloat(Int(i/2)) + fromWideSpace, y: upper, width: viewWidth, height: viewHeight))
                self.view.addSubview(orderButton)
            }
            else{
                let orderButton = OrderSheet(frame: CGRect(x: wideSpace * CGFloat(Int(i/2)) + fromWideSpace, y: lower, width: viewWidth, height: viewHeight))
                self.view.addSubview(orderButton)
            }
        }
        //alamofire
        AF.request("https://connect.squareup.com/v2/orders/search", method: .post, parameters: self.parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{res in
            guard let json = res.data else{
                print("no_json")
                return
            }
            var menues: [String] = []
            self.orders = try! JSONDecoder().decode(Response.self, from: json)
            
            if self.orders != nil {
                for order in self.orders!.orders{
                    var menu: String = ""
                    for i in 0 ..< order.lineItems.count{
                        menu.append(order.lineItems[i].name)
                        menu.append(":\t")
                        menu.append(order.lineItems[i].quantity)
                        if(i != order.lineItems.count - 1){
                            menu.append("\n")
                        }
                    }
                    menues.append(menu)
                }
                OrderSheet.addData(data: menues)
                print(OrderSheet.views)
            }
            else{print("decode failed")}
        }
    }
    
    //left
    @objc func editMember() {
        let second = MemberController()
        self.navigationController?.pushViewController(second, animated: true)
    }
    
    //right
    @objc func seeOrderStock() {
        let second = OrderStockController()
        self.navigationController?.pushViewController(second, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

class OrderSheet: UIView{
    var menu: String!
    var mainButton: UIButton!
    var waveView: UIView!
    var status: Int! //-1, 0, or 1
    static var views: [OrderSheet] = [] //search button's title
    static var orderStock: [String] = [] //input: menues from json data (reformed)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.mainButton = UIButton()
        self.waveView = UIView()
        self.waveView.layer.borderWidth = 2.0
        self.mainButton.setTitle(self.menu, for: [])
        self.mainButton.setTitleColor(UIColor.white, for: [])
        self.waveView.layer.cornerRadius = 10
        self.waveView.backgroundColor = UIColor.clear
        self.mainButton.layer.cornerRadius = 10
        self.status = -1
        self.mainButton.titleLabel?.numberOfLines = 0
        OrderSheet.views.append(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        mainButton.frame = self.frame
        waveView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(mainButton)
        mainButton.addSubview(waveView)
        waveView.isUserInteractionEnabled = false
        mainButton.center = waveView.center
        self.mainButton.addTarget(self, action: #selector(self.onTap(_:)), for: .touchUpInside)
        self.display(status: self.status)
        OrderSheet.addData(data: [])
        
    }
    
    func display(status: Int){
        switch status {
        case 1:
            self.mainButton.setTitle(self.menu, for: [])
            
            self.mainButton.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
            self.waveView.layer.borderColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 0.7).cgColor
            //wave motion
            UIView.animate(withDuration: 1.5, delay: 0.0, options: [.repeat], animations: {
                let affine = CGAffineTransform(a: 1.2, b: 0, c: 0, d: 1.2, tx: 0, ty: 0)
                self.waveView.transform = affine
                self.waveView.alpha = 0
            }, completion: nil)
        
        case 0:
            waveView.layer.removeAllAnimations()
            let affine = CGAffineTransform(a: 1.0, b: 0, c: 0, d: 1.0, tx: 0, ty: 0)
            self.waveView.transform = affine
            mainButton.backgroundColor = UIColor(red: 63 / 255, green: 185 / 255, blue: 185 / 255, alpha: 1.0)
            //reset waveView
            self.waveView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            self.waveView.alpha = 0.7
            
        case -1:
            if(OrderSheet.orderStock.isEmpty){
                self.menu = nil
                self.mainButton.setTitle(self.menu, for: [])
                mainButton.backgroundColor = UIColor(red: 185 / 255, green: 185 / 255, blue: 185 / 255, alpha: 1.0)
            }
            else{
                self.menu = OrderSheet.orderStock.first
                self.mainButton.setTitle(self.menu, for: [])
                OrderSheet.orderStock.removeFirst()
                
                self.status = 1
                self.display(status: self.status)
            }
            
        default:
            print("Invalid Input")
        }
    }
    
    static func addData(data: [String]){
        OrderSheet.orderStock += data
        for view in OrderSheet.views{
            if(view.menu == nil && (!OrderSheet.orderStock.isEmpty)){
                view.menu = OrderSheet.orderStock.first
                OrderSheet.orderStock.removeFirst()
                view.status = 1
                view.display(status: view.status)
            }
        }
    }
    
    //when tapped
    @objc func onTap(_ sender: UIButton){
        self.status -= 1
        display(status: self.status)
    }
    
}

//define json's struct
//encode
/*
struct Parameters{
    let locationIds: [String]
    let startAt: String
    let endAt: String
}

extension Parameters: Encodable {
    private struct CustomCodingKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) { return nil }

        static let locationIds = CustomCodingKey(stringValue: "location_ids")!
        static let query = CustomCodingKey(stringValue: "query")!
        static let filter = CustomCodingKey(stringValue: "filter")!
        static let dateTimeFilter = CustomCodingKey(stringValue: "date_time_filter")!
        static let createdAt = CustomCodingKey(stringValue: "createdAt")!
        static let startAt = CustomCodingKey(stringValue: "start_at")!
        static let endAt = CustomCodingKey(stringValue: "end_at")!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKey.self)
        try container.encode(locationIds, forKey: .locationIds)
        var queryContainer = container.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .query)
        var filterContainer = queryContainer.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .filter)
        var dateTimeFilterContainer = filterContainer.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .dateTimeFilter)
        var createdAtContainer = dateTimeFilterContainer.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .createdAt)
        /*
        var startAtContainer = createdAtContainer.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .startAt)
        var endAtContainer = createdAtContainer.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .endAt)
        */
        try createdAtContainer.encode(startAt, forKey: .startAt)
        try createdAtContainer.encode(endAt, forKey: .endAt)
    }
}
*/

//decode
struct Response: Decodable{
    struct Order: Decodable{
        struct LineItem: Decodable{
            let quantity: String
            let name: String
        }
        enum CodingKeys: String, CodingKey{
            case lineItems = "line_items"
        }
        let lineItems: [LineItem]
    }
    let orders: [Order]
}
