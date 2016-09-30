//
//  ViewController.swift
//  Shopicruit - Winter
//
//  Created by Roberta Voulon on 2016-09-30.
//  Copyright © 2016 Roberta Voulon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate : AppDelegate!
    //    var timekeepers: [Timekeeper] = [Timekeeper]()
    var runningTotal = 0.00 // END RESULT: 2290.74 for all clocks and watches
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // 1. set the parameters
        // TODO: Think about the page numbers here... use components to build out the URL
        
        getPricesForClocksAndWatches(forPageNumber: 1)
        
        
    }
    
    func getPricesForClocksAndWatches(forPageNumber pageNumber: Int) {
        
        // 2. build URL and 3. configure the request
        let url: URL = URL(string: "http://shopicruit.myshopify.com/products.json?page=\(pageNumber)")!
        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print(request.url!)
        
        // 4. make the request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            
            // Was there an error?
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            // Did we get a successful response code?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned an unsuccessful status code")
                return
            }
            
            // Did we get any data returned?
            guard let data = data else {
                print("Your request did not return any data")
                return
            }
            
            // 5. parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch {
                print("Could not parse the data returned as a JSON object: \(data)")
                return
            }
            
            guard let products = parsedResult["products"] as? [[String : AnyObject]] else {
                print("JSON data did not contain a `products` key: \(parsedResult)")
                return
            }
            
            
            
            // 6. use the data
            // TODO: Send the products to a function in Timekeeper? like this:
            //            self.timekeepers.append(contentsOf: Timekeeper.fromProducts(products))
            // perform ui updates on main: self.view.reloadData()
            
            for product in products {
                guard let productType = product["product_type"] as? String else {
                    print("Error getting product type of product: \(product)")
                    return
                }
                
                if productType == "Clock" || productType == "Watch" {
                    
                    guard let variants = product["variants"] as? [[String : AnyObject]] else {
                        print("Error getting variants for product: \(product)")
                        return
                    }
                    
                    for variant in variants {
                        
                        guard let price = (variant["price"])?.doubleValue else {
                            print("Could not get price for product variant: \(variant)")
                            return
                        }
                        
                        self.runningTotal.add(price)
                        print("\(self.runningTotal) - \(productType)")
                    }
                }
            }
            
            if pageNumber < 5 {
                self.getPricesForClocksAndWatches(forPageNumber: (pageNumber + 1))
            }
        }

        // 7. Start the request
        task.resume()
        
    }
    
}

