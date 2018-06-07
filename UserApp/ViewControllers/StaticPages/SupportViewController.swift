//
//  SupportViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/16/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class SupportViewController: UIViewController {
        
    // MARK: Variables
    //MARK:- =================================================

    var isQuerySelected = [false, false, false, false, false, false, false, false, false, false]
    var queryDict = JSONDictionaryArray()
    var selectedIndexPath: IndexPath?
    
    // MARK: IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var queriesTableView: UITableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var addNewBtn: UIButton!

    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.postQueryApi()
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {
        
        self.queriesTableView.dataSource = self
        self.queriesTableView.delegate = self
        self.queriesTableView.estimatedRowHeight = 40
    }
    
    func postQueryApi() {
        
        guard CommonClass.isConnectedToNetwork else{
            showToastWithMessage(NO_INTERNET)
            return
        }
        CommonClass.startLoader("")
        
        let params: [String: AnyObject] = ["action": "view" as AnyObject]
        
        ServiceController.postQueryService(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
                self.queryDict = json["result"].arrayObject as? JSONDictionaryArray ?? [["":""]]
                
            self.queriesTableView.reloadData()
                
            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
    
    func formatDate(_ date:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date1 = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        let strDate = dateFormatter.string(from: date1!)
        return strDate
    }
    
    func cellHeight(_ indexPath: IndexPath) -> CGFloat {
        
        guard let query = self.queryDict[indexPath.row]["title"] as? String else { fatalError("Response format incorrect") }
        
        let heightOfQueryLabel: CGFloat = query.height(withConstrainedWidth: screenWidth - 69, font: UIFont(name: "SFUIDisplay-Regular", size: 13)!)
            
        let heightOfAnswerLabel: CGFloat = ((self.queryDict[indexPath.row]["answer"] as? String) ?? "No answer").height(withConstrainedWidth: screenWidth - 44, font: UIFont(name: "SFUIDisplay-Regular", size: 11)!)
        
        if self.selectedIndexPath == indexPath{

            return 78+heightOfQueryLabel + heightOfAnswerLabel

        }else{

            return 70 + heightOfQueryLabel

        }
        //return self.isQuerySelected[indexPath.row] ? 78+heightOfQueryLabel+heightOfAnswerLabel : 70+heightOfQueryLabel
    }
    
    //MARK:- IBActions
    //MARK:- =================================================

    @IBAction func addNewBtnTapped(_ sender: UIButton) {
        
        let postQueryScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "PostQueryViewController") as! PostQueryViewController
        
        self.navigationController?.pushViewController(postQueryScene, animated: true)
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: Tableview Datasource life cycle methods
extension SupportViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.queryDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueryTableViewCell", for: indexPath) as! QueryTableViewCell
        
        guard let query = self.queryDict[indexPath.row]["title"] as? String, let postedDate = self.queryDict[indexPath.row]["date_created"] as? String else { fatalError("Response format incorrect") }
        if self.selectedIndexPath == indexPath{
            cell.queryAnswerLabel.isHidden = false
        }else{
            cell.queryAnswerLabel.isHidden = true

        }
        
        let date = postedDate.convertTimeWithTimeZone(formate: DateFormate.dateOnly)
        
        cell.populateCell(withQuery: query, onDatePosted: "Posted On: \(date)", withAnswer: ((self.queryDict[indexPath.row]["response"] as? String) ?? "No answer") )
        return cell
        
    }
}

// MARK: Tableview Datasource life cycle methods
//MARK:- =================================================

extension SupportViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: self.queriesTableView.frame.width, height: 60))
        sectionView.backgroundColor = self.queriesTableView.backgroundColor
        
        let label = UILabel(frame: sectionView.frame)
        label.text = "POST QUERIES POSTED BY YOU"
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 14)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        
        sectionView.addSubview(label)
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return cellHeight(indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //self.isQuerySelected[indexPath.row] = true
        if self.selectedIndexPath != nil{
            self.selectedIndexPath = nil
        }else{
            self.selectedIndexPath = indexPath

        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.isQuerySelected[indexPath.row] = false
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
}

// MARK: Query tableview cell (Not used anywhere)
//MARK:- =================================================

class QueryTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var postedDateLabel: UILabel!
    @IBOutlet weak var queryAnswerLabel: UILabel!
    
    // Table View Cell Life Cycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.queryLabel.text = nil
        self.postedDateLabel.text = nil
        self.queryAnswerLabel.text = nil
    }
    
    // Private Methods
    func populateCell(withQuery query: String, onDatePosted postedDate: String, withAnswer answer: String) {
        self.queryLabel.text = query
        self.postedDateLabel.text = postedDate
        self.queryAnswerLabel.text = answer
    }
}
