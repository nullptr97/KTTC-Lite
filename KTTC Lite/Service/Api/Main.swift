//
//  Main.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 11.10.2021.
//

import Foundation
import UIKit
import ObjectMapper

open class KTTCApi: NSObject {
    enum GameType: String {
        case bb = "https://api.worldoftanks.ru/wot"
        case blitz = "https://api.wotblitz.ru/wotb"
    }
    
    enum MethodGroup: String {
        case auth
        case account
        case tanks
        case encyclopedia
    }
    
    enum Method: String {
        case login
        case info
        case tanks
        case stats
        case list
        case vehicles
    }
    
    enum Parameters: String {
        case applicationId = "application_id"
        case accountId = "account_id"
        case tankId = "tank_id"
        case search
        case type
        case inGarage = "in_garage"
        case fields
    }

    private let applicationId = "509582c9ba46e713348fff689cfdec0c"
    private var baseURLSession: URLSession {
        let config: URLSessionConfiguration = .default
        let session: URLSession = .init(configuration: config)
        return session
    }
    
    private var averageData: Foundation.Data?
    
    func request<T: Mappable>(with model: T.Type, gameType: GameType = .bb, _ methodGroup: MethodGroup, _ method: Method, _ parameters: [Parameters : String] = [:]) -> Signal<T, NSError> {
        return Signal { [weak self] observer in
            guard let self = self else { return MetaDisposable() }
            let completed = Atomic<Bool>(value: false)
            var dataTask: URLSessionDataTask?

            if let url = self.get(url: gameType.rawValue +/ methodGroup.rawValue +/ method.rawValue +/ "", from: parameters) {
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 25)
                
                dataTask = self.baseURLSession.dataTask(with: request) { data, response, error in
                    let _ = completed.swap(true)
                    if let error = error as NSError? {
                        observer.putError(error)
                    }
                    
                    if let data = data {
                        if let stringJSON = String(data: data, encoding: .utf8), let object = Mapper<T>().map(JSONString: stringJSON) {
                            if !stringJSON.contains(":null}}") {
                                observer.putNext(object)
                                observer.putCompletion()
                            } else {
                                observer.putError(NSError(domain: NSCocoaErrorDomain, code: 3804, userInfo: ["NSLocalizedDescription" : "Данных пользователя нет"]))
                            }
                        } else {
                            observer.putError(NSError(domain: NSCocoaErrorDomain, code: 3804, userInfo: ["NSLocalizedDescription" : "Объект не может быть создан"]))
                        }
                    }
                }
                
                dataTask?.resume()
            } else {
                observer.putError(NSError(domain: NSCocoaErrorDomain, code: 1287, userInfo: ["NSLocalizedDescription" : "Неверный URL"]))
            }
            
            return BlockDisposable {
                if !completed.with({ $0 }) {
                    dataTask?.cancel()
                }
            }
        }
    }
    
    func requestXVM<T: Mappable>(with model: T.Type) -> Signal<T, NSError> {
        return Signal { [weak self] observer in
            guard let self = self else { return MetaDisposable() }
            let completed = Atomic<Bool>(value: false)

            let url = URL(string: "https://static.modxvm.com/wn8-data-exp/json/wn8exp.json")!
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
            
            let dataTask = self.baseURLSession.dataTask(with: request) { data, response, error in
                let _ = completed.swap(true)
                if let error = error as NSError? {
                    print(error)
                    observer.putError(error)
                }
                
                if let data = data {
                    if let stringJSON = String(data: data, encoding: .utf8), let object = Mapper<T>().map(JSONString: stringJSON) {
                        observer.putNext(object)
                        observer.putCompletion()
                    } else {
                        observer.putError(NSError(domain: NSCocoaErrorDomain, code: 3804, userInfo: ["NSLocalizedDescription" : "Объект не может быть создан"]))
                    }
                }
            }
            
            dataTask.resume()
            
            return BlockDisposable {
                if !completed.with({ $0 }) {
                    dataTask.cancel()
                }
            }
        }
    }
    
    private func get(url: String, from parameters: [Parameters : String] = [:]) -> URL? {
        var stringParameters: String = "application_id=509582c9ba46e713348fff689cfdec0c"
        _ = parameters.enumerated().map { index, kv in
            stringParameters = stringParameters +& kv.key.rawValue += kv.value
        }
        let stringURL = url +? stringParameters
        if stringURL.isValidURL {
            return URL(string: stringURL.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: ""))
        } else {
            return nil
        }
    }
}

infix operator +/ : AdditionPrecedence
infix operator +? : AdditionPrecedence
infix operator += : AdditionPrecedence
infix operator +& : AdditionPrecedence

extension String {
    static func +/ (left: String, right: String) -> String {
        return left + "/" + right
    }
    
    static func +? (left: String, right: String) -> String {
        return left + "?" + right
    }
    
    static func += (left: String, right: String) -> String {
        return left + "=" + right
    }
    
    static func +& (left: String, right: String) -> String {
        return left + "&" + right
    }
    
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

public final class BlockDisposable: Disposable {
    private var handler: (() -> Void)?
    
    public var isDisposed: Bool {
        return handler == nil
    }
    
    public init(_ handler: @escaping () -> Void) {
        self.handler = handler
    }
    
    public func dispose() {
        handler?()
        handler = nil
    }
}

open class Constants {
    static var expectedValues: [Dates] = []
}
