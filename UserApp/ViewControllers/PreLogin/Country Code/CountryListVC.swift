//
//  CountryListVC.swift
//  WAIN Application
//
//  Created by Appinventiv on 13/01/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import IQKeyboardManager

//MARK:- Delegate ShowCodeDetailDelegate
//MARK:-
protocol ShowCountryDetailDelegate: class
{
    func getCountryDetails(_ text:String!,countryName:String!,Max_NSN_Length:Int!,Min_NSN_Length:Int!,countryShortName : String!)
}

class CountryListVC: UIViewController, UISearchBarDelegate {
    
    //MARK:- IBOutlets and Properties
    //MARK:-
    @IBOutlet weak var customNavigationBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBuuton: UIButton!
    @IBOutlet weak var tittleLabel: UILabel!
    
    var sections = [Section]()
    var filteredSection = [Section]()
    var countryArray = [[String:AnyObject]]()
    var filteredData = [[String:AnyObject]]()
    var selectedIndexPath:IndexPath? = nil

    var Max_NSN:Int!
    var Min_NSN:Int!
    var country_CODE:String!
    var country_NAME:String!
    var countryShortName : String!
    
    weak var delegate:ShowCountryDetailDelegate?
    
    var sectionTitles : [String] = []
    
    let collation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
    
    
    //MARK:-
    //MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBarView.backgroundColor = UIColor(colorLiteralRed: 224/255.0, green: 0/255.0, blue: 83/255.0, alpha: 1)
        self.initializeSections()
        IQKeyboardManager.shared().isEnabled = false
        self.resignFirstResponder()
        self.searchBar.delegate = self
        self.fetchCountryCodeFromSqlite()
        self.searchBar.backgroundColor = UIColor.clear
        self.searchBar.barTintColor = UIColor.clear
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton)
    {
        if !sender.isSelected
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                sender.isSelected = true
                self.searchBuuton.setImage(UIImage(named: "cross1"), for: UIControlState.selected)
                self.tittleLabel.alpha = 0.0
                }, completion: { finished in
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                        self.searchBar.alpha = 1.0
                        }, completion: { (Bool) -> Void in
                            self.searchBar.becomeFirstResponder()
                    })
            })
        }
        else
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                sender.isSelected = false
                self.searchBuuton.setImage(UIImage(named: "search"), for: UIControlState.selected)
                self.searchBar.alpha = 0.0
                }, completion: { finished in
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                        self.tittleLabel.alpha = 1.0
                        }, completion: { (Bool) -> Void in
                            self.searchBar.resignFirstResponder()
                    })
            })
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onTapDoneButton(_ sender: UIButton)
    {
        if self.selectedIndexPath != nil {
            
            delegate?.getCountryDetails(self.country_CODE,countryName: self.country_NAME,Max_NSN_Length: self.Max_NSN,Min_NSN_Length: self.Max_NSN,countryShortName: self.countryShortName)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:-fetchCountryCodeFromSqlite
    //:------------------------------
    func fetchCountryCodeFromSqlite()
    {
        let handler: VoiceeCountryHandler = VoiceeCountryHandler()
        self.countryArray  = handler.fetchCountry().sortedArray(using: NSArray(object: NSSortDescriptor(key: "CountryEnglishName", ascending: true)) as! [NSSortDescriptor]) as![[String:AnyObject]]
        self.filteredData = self.countryArray
        self.addCountriesToSections()
        self.tableView.reloadData()
    }
    
    //TO_____DO
    //MARK:-Country Model class
    //:====
    class Country:NSObject
    {
        let countryName: String
        var countryCode: String
        var max_NSN_NO:Int!
        var min_NSN_NO:Int!
        var countryShortName : String
        
        init(name: String, countryCode: String,max_NSN_NO:Int!,min_NSN_NO:Int!,countryShortName:String) {
            self.countryName = name
            self.countryCode = countryCode
            self.max_NSN_NO = max_NSN_NO
            self.min_NSN_NO = min_NSN_NO
            self.countryShortName = countryShortName
        }
    }
    
    //Mark:-Model Class
    //:-
    class Section
    {
        
        var countries: [Country] = []
        var sectionIndex: Int!
        func addCountry(_ country: Country) {
            self.countries.append(country)
        }
    }
    
    //MARK:-initializeSections
    //:-
    func initializeSections()
    {
        for _  in 0..<self.collation.sectionIndexTitles.count {
            self.sections.append(Section())
        }
    }
    
    func addCountriesToSections()
    {
        // create users from the name list
        for section in self.sections
        {
            if section.countries.count > 0
            {
                section.countries.removeAll()
            }
        }
        self.filteredSection.removeAll()
        let _: [Country] = self.filteredData.map { data in
            let country = Country(name: data["CountryEnglishName"] as! String, countryCode: data["CountryCode"] as! String,max_NSN_NO: data["Max_NSN"] as! Int, min_NSN_NO: data["Min_NSN"] as! Int,countryShortName: data["ISOCode"] as! String)
            let sectionIndex: Int = self.collation.section(for: country, collationStringSelector: #selector(getter: Country.countryName))
            self.sections[sectionIndex].addCountry(country)
            self.sections[sectionIndex].sectionIndex = sectionIndex
            return country
        }
        //Mark:-Sort  for each section
        //:-
        for section in self.sections {
            section.countries = self.collation.sortedArray(from: section.countries, collationStringSelector: #selector(getter: Country.countryName)) as! [Country]
            if section.countries.count > 0
            {
                self.filteredSection.append(section)
            }
        }
    }
    
    //MARK:- UISearchBarDelegate Method
    //MARK:-
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.characters.count > 0
        {
            self.filteredData = self.countryArray.filter({(dict: [String: AnyObject]) -> Bool in
                let array: [String] = (dict["CountryEnglishName"]!.lowercased).characters.split {$0 == " "}.map { String($0) }
                var matchedString:Bool = false
                print(array)
                
                for str in array
                {
                    matchedString = str.hasPrefix(searchText.lowercased())
                    if matchedString
                    {
                        break;
                    }
                }
                return matchedString
            })
            
            print("\(self.filteredData)")
            
        }
        else
        {
            self.filteredData = self.countryArray
        }
        self.addCountriesToSections()
        self.tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.endEditing(true)
        self.view.endEditing(true)
    }
    
}

//MARK:-
//MARK:- TableView DataSouce and Delegate
extension CountryListVC : UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        printlnDebug(self.filteredSection)
        return self.filteredSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.filteredSection[section].countries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int)
        -> String?
    {
        if !self.filteredSection[section].countries.isEmpty
        {
            return self.collation.sectionTitles[self.filteredSection[section].sectionIndex] as String
        }
        return ""
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let subView = UIView()
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 25)
        subView.frame = CGRect(x: 15, y: 1, width: screenWidth, height: 25)

        view.backgroundColor = UIColor.clear
        subView.backgroundColor = UIColor.lightGray
        let lab : UILabel = UILabel()
        lab.font = UIFont.boldSystemFont(ofSize: 15)
        lab.textColor = UIColor(colorLiteralRed: 224/255.0, green: 0/255.0, blue: 83/255.0, alpha: 1)
        lab.frame = CGRect(x: 70, y: 1, width: screenWidth, height: 25)
        lab.text = self.collation.sectionTitles[self.filteredSection[section].sectionIndex] as String
        view.addSubview(subView)
        subView.addSubview(lab)
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryListCell", for: indexPath) as! CountryListCell
        
        let country_Info = self.filteredSection[indexPath.section].countries[indexPath.row]
        
        cell.countryLabel.text! = country_Info.countryName
        cell.isdCodeLabel.text! = country_Info.countryCode
        
        self.Max_NSN = country_Info.max_NSN_NO
        self.Min_NSN = country_Info.min_NSN_NO
        self.countryShortName = country_Info.countryShortName
        
        if (self.selectedIndexPath == indexPath){
            cell.chekImage.image = UIImage(named: "tick")
            self.view.endEditing(true)
            print("\(self.country_CODE),\(self.country_NAME),\(self.Max_NSN),\(self.Min_NSN),\(self.countryShortName)")
           // delegate?.getCountryDetails(self.country_CODE, countryName: self.country_NAME, Max_NSN_Length: self.Max_NSN, Min_NSN_Length: self.Min_NSN,countryShortName:self.countryShortName)
        }
        else{
            cell.chekImage.image = UIImage(named: "uncheck")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country_Info = self.filteredSection[indexPath.section].countries[indexPath.row]
        self.country_CODE = country_Info.countryCode
        self.country_NAME = country_Info.countryName
        self.Max_NSN = country_Info.max_NSN_NO
        self.Min_NSN = country_Info.min_NSN_NO
        self.countryShortName = country_Info.countryShortName
        
        if self.selectedIndexPath == indexPath
        {
            self.selectedIndexPath = nil
            self.tableView.reloadRows(
                at: [indexPath],
                with:UITableViewRowAnimation.none)
            tableView.deselectRow(at: indexPath, animated:false)
            return
        }
        
        if selectedIndexPath != nil
        {
            self.selectedIndexPath = indexPath
            self.tableView.reloadData()
            return
        }
        
        self.selectedIndexPath = indexPath
        tableView.reloadRows(at: [indexPath],with:UITableViewRowAnimation.none)
    }
}
