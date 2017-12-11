//
//  TodayViewController.swift
//  TodayPrice
//
//  Created by Daniel Reicher on 10.12.17.
//  Copyright © 2017 Daniel Reicher. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON


class TodayViewController: UIViewController, NCWidgetProviding {
    

    
    var bitcoinKurs: Double?
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    var finalURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCEUR"
    
    
    @IBOutlet weak var labelData: UILabel!
    
    var selectedSymbol = "€"
    var currencyName = "EUR"
    
    @IBAction func refreshBtnPressed(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let symbol = UserDefaults(suiteName: "group.bitcoinApp")!.string(forKey: "symbolWidget") {
            selectedSymbol = symbol
        }
        if let shortcut = UserDefaults(suiteName: "group.bitcoinApp")!.string(forKey: "nameWidget") {
            currencyName = shortcut
        }
        
        getBitcoinData(url: createFinalURL(baseURL: baseURL, currency: currencyName))
        
    }
    
    func createFinalURL(baseURL: String, currency: String) -> String{
        return baseURL + currency
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.noData)
    }
    
    
    func getBitcoinData(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                print("Succsess!")
                let bitcoinData: JSON = JSON(response.result.value!)
                self.getJSON(input: bitcoinData)
            } else {
                print("Network Issue")
                self.labelData.text = "Network Issue"
                
            }
        }
        
    }
    
    
    func getJSON(input: JSON) {
        
        let json = JSON(input)
        let name = json["last"].doubleValue
        labelData.text = "\(selectedSymbol) \(name)"
    }
    
}


