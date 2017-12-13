//
//  ViewController.swift
//  BitcoinApp
//
//  Created by Daniel Reicher on 05.12.17.
//  Copyright © 2017 Daniel Reicher. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON




class MainVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let symbolArray =
        ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    var selectedSymbol = "€"
    var currencyName = "EUR"
    var finalURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCEUR"
    
    
    
    @IBOutlet weak var kursLbl: UILabel!
    @IBOutlet weak var kursWertLbl: UILabel!
    @IBOutlet weak var datumLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var lastDay: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var aktuellerWertLbl: UILabel!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lastWeekLbl: UILabel!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var dayImg: UIImageView!
    @IBOutlet weak var weekImg: UIImageView!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var refreshLbl: UILabel!
    
    
    var bitcoinKurs: Double? {
        didSet {
            calculateBitcoin(txtInput: txtField.text!, kurs: bitcoinKurs!)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtField.layer.cornerRadius = 5
        refreshBtn.layer.cornerRadius = 5
        
        txtField.delegate = self
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        txtField.text = UserDefaults.standard.string(forKey: "ownBitcoins")
        UserDefaults.standard.register(defaults: ["symbol" : "€"])
        UserDefaults.standard.register(defaults: ["currency" : "EUR"])
        selectedSymbol = UserDefaults.standard.string(forKey: "symbol")!
        currencyName = UserDefaults.standard.string(forKey: "currency")!
        UserDefaults(suiteName: "group.bitcoinApp")!.set(selectedSymbol, forKey: "symbolWidget")
        UserDefaults(suiteName: "group.bitcoinApp")!.set(currencyName, forKey: "nameWidget")
    }
    
    
    @objc func applicationDidBecomeActive(_ notification: NSNotification) {
        getBitcoinData(url: finalURL)
    }
    
    
    @IBAction func refreshBtnPressed(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.impactOccurred()
        } else {
            // Fallback on earlier versions
        }
        
        getBitcoinData(url: finalURL)
        if let kurs = bitcoinKurs {
            calculateBitcoin(txtInput: txtField.text!, kurs: kurs)
        }
         
    }
    
    
    @IBAction func wertInput(_ sender: UITextField) {
        if let kurs = bitcoinKurs {
            calculateBitcoin(txtInput: txtField.text!, kurs: kurs)
        }
        UserDefaults.standard.set(sender.text, forKey: "ownBitcoins")
    }
    

    @IBAction func currencyBtnPressed(_ sender: UIButton) {
        hideShowLabels()
    }
    
    
    
    func calculateBitcoin(txtInput: String, kurs: Double) {
        
        if bitcoinKurs != nil && txtField.text != nil {
            let formattedValue = numberFormatter(input: txtInput)
            let calaculated = Double(formattedValue) * kurs
            let output = round(100*calaculated)/100
            aktuellerWertLbl.text = "\(selectedSymbol) \(output)"
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Neworking
    
    func getBitcoinData(url: String) {

        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                print("Succsess!")
                let bitcoinData: JSON = JSON(response.result.value!)
                self.getJSON(input: bitcoinData)
            } else {
                print("Network Issue")
                self.kursLbl.text = "Network Issue"
                self.kursLbl.font = self.kursLbl.font.withSize(22)
                self.kursWertLbl.text = " "
                self.lastDay.text = " "
                self.lastWeekLbl.text = " "
                self.weekImg.image = UIImage(named: "")
                self.dayImg.image = UIImage(named: "")
            }
        }
        
    }
    
    
    func getJSON(input: JSON) {
        
        let json = JSON(input)
        let lastPrice = json["last"].doubleValue
        let date = json["display_timestamp"].stringValue
        let percentDay = json["changes"]["percent"]["day"].doubleValue
        let percentWeek = json["changes"]["percent"]["week"].stringValue
        let dateArray = date.components(separatedBy: " ")
        let newDate = dateArray[0].replacingOccurrences(of: "-", with: ".")
        let newTime = dateArray[1]
        let formattedDay = String(percentDay)
        kursWertLbl.text = "\(selectedSymbol) \(lastPrice)"
        datumLbl.text = newDate
        timeLbl.text = UTCToLocal(date: newTime)
        bitcoinKurs = lastPrice
        kursLbl.text = "Price in \(currencyName):"
        if formattedDay.contains("-") {
            lastDay.text = "Day: \(formattedDay) %"
            dayImg.image = UIImage(named: "ArrowDown")
        } else {
            lastDay.text = "Day: +\(formattedDay) %"
            dayImg.image = UIImage(named: "ArrowUp")
        }
        if percentWeek.contains("-") {
            lastWeekLbl.text = "Week: \(percentWeek) %"
            weekImg.image = UIImage(named: "ArrowDown")
        } else {
            lastWeekLbl.text = "Week: +\(percentWeek) %"
            weekImg.image = UIImage(named: "ArrowUp")
        }
    }
    
    
    
    func numberFormatter(input: String) -> Double{
        let formatter = NumberFormatter()
        
        formatter.decimalSeparator = ","
        if let number = formatter.number(from: input) {
            return number.doubleValue
        } else {
            formatter.decimalSeparator = "."
            if let number = formatter.number(from: input) {
                return number.doubleValue
            }
            return 0.0
        }
        
    }
    
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: dt!)
    }
    
    
    fileprivate func hideShowLabels() {
        if currencyPicker.isHidden == true {
            currencyPicker.isHidden = false
            dayImg.isHidden = true
            weekImg.isHidden = true
            kursLbl.isHidden = true
            kursWertLbl.isHidden = true
            refreshBtn.isHidden = true
            refreshLbl.isHidden = true
            lastWeekLbl.isHidden = true
            lastDay.isHidden = true
        } else {
            currencyPicker.isHidden = true
            dayImg.isHidden = false
            weekImg.isHidden = false
            kursLbl.isHidden = false
            kursWertLbl.isHidden = false
            refreshBtn.isHidden = false
            refreshLbl.isHidden = false
            lastWeekLbl.isHidden = false
            lastDay.isHidden = false
        }
    }
    
    
    //MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        finalURL = baseURL + currencyArray[row]
        selectedSymbol = symbolArray[row]
        currencyName = currencyArray[row]
        UserDefaults.standard.set(selectedSymbol, forKey: "symbol")
        UserDefaults.standard.set(currencyName, forKey: "currency")
        UserDefaults(suiteName: "group.bitcoinApp")!.set(selectedSymbol, forKey: "symbolWidget")
        UserDefaults(suiteName: "group.bitcoinApp")!.set(currencyName, forKey: "nameWidget")
        getBitcoinData(url: finalURL)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "American Typewriter", size: 30)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = currencyArray[row]
        pickerLabel?.textColor = UIColor.white
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35.0
    }
    
}
