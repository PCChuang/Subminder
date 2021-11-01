//
//  CurrencyManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/26.
//

import Foundation

protocol CurrencyManagerDelegate: AnyObject {

    func manager(_ manager: CurrencyManager, didGet currencies: [String])

    func manager(_ manager: CurrencyManager, didGet values: [Double])
}

class CurrencyManager {

    var currencies: [String] = []

    var values: [Double] = []

    weak var delegate: CurrencyManagerDelegate?

    func getConversionRate(currencies: [String], values: [Double], completion: @escaping () -> Void) {

        let configuration = URLSessionConfiguration.default

        let session = URLSession(configuration: configuration)

        guard let url = URL(string: "https://apilayer.net/api/live?access_key=2a6f4e22f7dde24f64f38725d7a0897d&currencies=TWD,USD,EUR,JPY,GBP,AUD,CAD,CHF,CNY,HKD,NZD&source=TWD&format=1") else {
            return
        }

        let task = session.dataTask(with: url) { (data, response, error) in

            if error != nil {

                print("ERROR --- \(error)")
            } else {

                if let content = data {

                    do {

                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject

                        if let rates = myJson["quotes"] as? NSDictionary {

                            for (key, value) in rates {

                                guard let key = key as? String else { return }

                                let newKey = key.deletePrefix("TWD")

                                self.currencies.append(newKey)

                                guard let value = value as? Double else { return }

                                self.values.append(value)

                                self.delegate?.manager(self, didGet: self.currencies)

                                self.delegate?.manager(self, didGet: self.values)
                            }
                            completion()
                        }
                    } catch {

                        print(error)
                    }
                }
            }
        }

        task.resume()
    }
}
