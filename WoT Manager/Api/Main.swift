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
    }

    private let applicationId = "509582c9ba46e713348fff689cfdec0c"
    private var baseURLSession: URLSession {
        let config: URLSessionConfiguration = .default
        let session: URLSession = .init(configuration: config)
        return session
    }
    
    func request<T: Mappable>(with model: T.Type, gameType: GameType = .bb, _ methodGroup: MethodGroup, _ method: Method, _ parameters: [Parameters : String] = [:]) -> Signal<T, NSError> {
        return Signal { [weak self] observer in
            guard let self = self else { return MetaDisposable() }
            let completed = Atomic<Bool>(value: false)

            let url = self.get(url: gameType.rawValue +/ methodGroup.rawValue +/ method.rawValue +/ "", from: parameters)
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
            
            let dataTask = self.baseURLSession.dataTask(with: request) { data, response, error in
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
                            observer.putError(NSError(domain: NSCocoaErrorDomain, code: 3804, userInfo: ["message" : "User data not found"]))
                        }
                    } else {
                        observer.putError(NSError(domain: NSCocoaErrorDomain, code: 3804, userInfo: ["message" : "Error map object"]))
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
                        observer.putError(NSError(domain: NSCocoaErrorDomain, code: 3804, userInfo: ["message" : "Error map object"]))
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
    
    private func get(url: String, from parameters: [Parameters : String] = [:]) -> URL {
        var stringParameters: String = "application_id=509582c9ba46e713348fff689cfdec0c"
        _ = parameters.enumerated().map { index, kv in
            stringParameters = stringParameters +& kv.key.rawValue += kv.value
        }
        let stringURL = url +? stringParameters
        return URL(string: stringURL.trimmingCharacters(in: .whitespacesAndNewlines))!
    }
}

struct Api {
    enum MethodGroup: String {
        case auth
        case account
        case tanks
    }
    
    enum Method: String {
        case login
        case info
        case tanks
        case stats
    }
    
    enum Parameters: String {
        case applicationId = "application_id"
        case accountId = "account_id"
        case tankId = "tank_id"
    }
    
    static let baseURL = "https://api.worldoftanks.ru/wot"
    static let applicationId = "509582c9ba46e713348fff689cfdec0c"
    
    static var baseURLSession: URLSession {
        let config: URLSessionConfiguration = .default
        let session: URLSession = .init(configuration: config)
        return session
    }

    static func request<T: Mappable>(with model: T.Type, _ methodGroup: MethodGroup, _ method: Method, _ parameters: [Parameters : String] = [.applicationId: applicationId]) -> Signal<T, NSError> {
        return Signal { subscriber in
            let completed = Atomic<Bool>(value: false)

            let url = get(url: baseURL +/ methodGroup.rawValue +/ method.rawValue +/ "", from: parameters)
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
            
            let dataTask = baseURLSession.dataTask(with: request) { data, response, error in
                let _ = completed.swap(true)
                if let error = error as NSError? {
                    DispatchQueue.main.async {
                        subscriber.putError(error)
                    }
                }
                
                if let data = data {
                    if let stringJSON = String(data: data, encoding: .utf8), let object = Mapper<T>().map(JSONString: stringJSON) {
                        DispatchQueue.main.async {
                            subscriber.putNext(object)
                            subscriber.putCompletion()
                        }
                    } else {
                        DispatchQueue.main.async {
                            subscriber.putError(NSError(domain: NSCocoaErrorDomain, code: 3804, userInfo: ["message" : "Error map object"]))
                        }
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
    
    static func xwmRequest<T: Mappable>(with model: T.Type, _ completion: @escaping (T?) -> Void) {
        let url = URL(string: "https://static.modxvm.com/wn8-data-exp/json/wn8exp.json")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
        
        let dataTask = baseURLSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }
            
            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                
                if statusCode == 200 {
                    print("status code: \(statusCode)")
                    if let data = data {
                        let t = Mapper<T>().map(JSONString: String(data: data, encoding: .utf8) ?? "No data")
                        completion(t)
                    }
                } else {
                    print("status code: \(statusCode)")
                    completion(nil)
                }
            }
        }
        
        dataTask.resume()
    }
    
    private static func get(url: String, from parameters: [Parameters : String] = [.applicationId: applicationId]) -> URL {
        var stringParameters: String = ""
        _ = parameters.enumerated().map { index, kv in
            if index == 0 {
                stringParameters = stringParameters + kv.key.rawValue += kv.value
            } else {
                stringParameters = stringParameters +& kv.key.rawValue += kv.value
            }
        }
        let stringURL = url +? stringParameters
        print(stringURL)
        return URL(string: stringURL)!
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
