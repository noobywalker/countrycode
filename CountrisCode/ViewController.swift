//
//  ViewController.swift
//  CountrisCode
//
//  Created by Waratnan Suriyasorn on 10/19/2559 BE.
//  Copyright © 2559 Waratnan Suriyasorn. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import Moya

class ViewController: UIViewController {

    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    var searchType = 0
    
    var countries: Variable<[Country]> = Variable([])
    var allCountries: [Country] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeSegment.rx
            .value
            .asObservable()
            .subscribe(onNext: { value in
                self.searchType = value
                print(value)
            })
            .addDisposableTo(disposeBag)
        
        searchBar.rx
            .text
            .asObservable()
            .filter {
                if $0.isEmpty {
                    self.countries.value = self.allCountries
                    return false
                }
                return true
            }
            .throttle(1.0, latest: true, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { text in
                self.search(text: text)
            }).addDisposableTo(disposeBag)
        
        
        countries.asObservable().bindTo(tableView.rx
            .items(cellIdentifier: "CountryCell",
                   cellType: UITableViewCell.self))  { row, country, cell in
                cell.textLabel?.text = country.name!
                cell.detailTextLabel?.text = "ISO Code:\(country.alpha2_code!), \(country.alpha3_code!)"
            }
            .addDisposableTo(disposeBag)

        getAllCountry()
    }
    
    func getAllCountry() {
        APIProvider.request(.all)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe { event in
                switch event {
                case let .next(response):
                    self.handlerAll(data: response)
                case let .error(error):
                    print(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func apiWith(text: String) -> Observable<Response> {
        var observ: Observable<Response>
            switch searchType {
            case 1: observ = APIProvider.request(.iso2Code(text))
            case 2: observ = APIProvider.request(.iso3Code(text))
            default: observ = APIProvider.request(.search(text))
        }
        
        return observ
    }
    
    func search(text: String) {
        apiWith(text: text).filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe { event in
                switch event {
                case let .next(response):
                    self.handler(data: response)
                case let .error(error):
                    print(error)
                default:
                    break
                }
            }
            .addDisposableTo(self.disposeBag)
    }
    
    func handlerAll(data: Any) {
        handler(data: data)
        allCountries = countries.value
    }
    
    func handler(data: Any) {
        
        let json = JSON(data)
        
        if searchType == 0 {
            countries.value = json["RestResponse"]["result"].array.flatMap(
                { $0.map { Country(name: $0["name"].string,
                                   alpha2_code: $0["alpha2_code"].string,
                                   alpha3_code: $0["alpha3_code"].string)
                    }}) ?? []
        } else {
            if let countryResponse = json["RestResponse"]["result"].dictionary.flatMap({ Country(name: $0["name"]?.string,
                                                                                                 alpha2_code: $0["alpha2_code"]?.string,
                                                                                                 alpha3_code: $0["alpha3_code"]?.string) })
            {
                countries.value = [countryResponse]
            } else {
                countries.value = []
            }
        }
    }
}

struct Country {
    var name: String?
    var alpha2_code: String?
    var alpha3_code: String?
}
