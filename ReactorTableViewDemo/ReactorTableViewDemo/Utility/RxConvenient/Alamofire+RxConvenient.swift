//
//  Alamofire+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/27.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift

public enum ResultErrorType {
    case dataIsEmpty
    case responseIsEmpty
    case requestParamsInvalid
    case resultTransform
    case resultZip
    case mapJSON
    case mapModel
    case mapListModel
    case successCode(Int)
    case filterCode(Int)
    case unknow
    
    var code: Int {
        switch self {
        case .filterCode(let code):
            return code
        default:
            return 1234
        }
    }
}

public struct ResultError {
    
    public static func create(with type: ResultErrorType) -> NSError {
        return NSError(domain: "ResultError: \(type)", code: type.code, userInfo: ["errorType": type])
    }
}

public typealias ObservableResult<T> = Observable<Result<T>>

public protocol APIRequestType {
    var url: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
}

extension APIRequestType {
    public var url: String { return "" }
    public var method: HTTPMethod { return .get }
    public var headers: HTTPHeaders? { return nil }
}

public protocol APIRequestable: APIRequestType {
    var params: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

extension APIRequestable {
    public var params: Parameters? { return nil }
    public var encoding: ParameterEncoding { return URLEncoding.default }
}

public protocol APIUploadable: APIRequestType {
    var encodingMemoryThreshold: UInt64 { get }
    var multipartFormData: (MultipartFormData) -> Void { get }
}

extension APIUploadable {
    public var encodingMemoryThreshold: UInt64 {
        return SessionManager.multipartFormDataEncodingMemoryThreshold
    }
    public var multipartFormData: (MultipartFormData) -> Void { return { _ in } }
}

open class APIRequest: APIRequestable {
    open var url: String = ""
    open var method: HTTPMethod = .get
    open var params: Parameters?
    open var encoding: ParameterEncoding = URLEncoding.default
    open var headers: HTTPHeaders?
    init(_ url: String = "",
         method: HTTPMethod = .get,
         params: Parameters? = nil,
         encoding: ParameterEncoding = URLEncoding.default,
         headers: HTTPHeaders? = nil) {
        self.url = url
        self.method = method
        self.params = params
        self.encoding = encoding
        self.headers = headers
    }
}

open class APIUploadRequest: APIUploadable {
    open var url: String = ""
    open var method: HTTPMethod = .post
    open var headers: HTTPHeaders?
    open var encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold
    open var multipartFormData: (MultipartFormData) -> Void = { _ in }
    init(_ url: String,
         method: HTTPMethod,
         headers: HTTPHeaders? = nil,
         encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
         multipartFormData: @escaping (MultipartFormData) -> Void = { _ in }) {
        self.url = url
        self.method = method
        self.headers = headers
        self.encodingMemoryThreshold = encodingMemoryThreshold
        self.multipartFormData = multipartFormData
    }
    
}

public class APIResponse {
    public var api: APIRequestType
    public var dataResponse: DataResponse<Any>?
    public var error: Error?
    public init(api: APIRequestType, dataResponse: DataResponse<Any>? = nil, error: Error? = nil) {
        self.api = api
        self.dataResponse = dataResponse
        self.error = error
    }
}

extension Alamofire.Request: Cancellable {
}

public struct RxAPI {
    
    public static let timeoutIntervalForRequest: TimeInterval = 15
    
    public static let sessionManager: SessionManager = {
        // 配置网络请求超时时间
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        return SessionManager(configuration: configuration)
    }()
    
    public static func request(_ api: APIRequestable) -> Observable<APIResponse> {
        return Observable.create { observer in
            let task = sessionManager.request(
                api.url.urlEncoding,
                method: api.method,
                parameters: api.params,
                encoding: api.encoding,
                headers: api.headers
            ).responseJSON { response in
                observer.on(.next(APIResponse(api: api, dataResponse: response)))
                observer.on(.completed)
            }
            return Disposables.create(with: task.cancel)
        }
    }
    
    public static func upload(_ api: APIUploadable) -> Observable<APIResponse> {
        return Observable.create { observer in
            let task = CancellableWrapper()
            sessionManager.upload(
                multipartFormData: api.multipartFormData,
                usingThreshold: api.encodingMemoryThreshold,
                to: api.url.urlEncoding,
                method: api.method,
                headers: api.headers,
                encodingCompletion: { result in
                    let apiResponse = APIResponse(api: api)
                    switch result {
                    case .success(let request, _, _):
                        task.innerCancellable = request
                        request.responseJSON(completionHandler: { (response) in
                            apiResponse.dataResponse = response
                            observer.on(.next(apiResponse))
                            observer.on(.completed)
                        })
                    case let .failure(error):
                        apiResponse.error = error
                        observer.on(.next(apiResponse))
                        observer.on(.completed)
                    }
                }
            )
            return Disposables.create(with: task.cancel)
        }
    }
}

public extension ObservableType where E == APIResponse {
    
    public func mapJSON() -> ObservableResult<NSDictionary> {
        return flatMap({ (apiResponse) -> ObservableResult<NSDictionary> in
            if let error = apiResponse.error {
                return .just(.failure(error))
            } else if let result = apiResponse.dataResponse?.result {
                if let error = result.error {
                    return .just(.failure(error))
                } else if let dict = result.value as? NSDictionary {
                    return .just(.success(dict))
                }
            }
            return .just(.failure(ResultError.create(with: .mapJSON)))
        })
    }
    
    public func mapModel<T>(_ T: T.Type, handle: @escaping (NSDictionary) -> T?) -> ObservableResult<T> {
        return mapJSON().flatMap({ (result) -> Observable<Result<T>> in
            if let error = result.error {
                return .just(.failure(error))
            } else if let data = result.value, let model = handle(data) {
                return .just(.success(model))
            }
            return .just(.failure(ResultError.create(with: .mapModel)))
        })
    }
    
    public func mapModel<T: Mappable>(_ T: T.Type, isBasic: Bool = false) -> ObservableResult<T> {
        return mapModel(T, handle: { (dict) -> T? in
            if isBasic {
                return T.basicMap(data: dict) as? T
            }
            return T.init(data: dict)
        })
    }
    
    public func basicMapModel<T: Mappable>(_ T: T.Type) -> ObservableResult<T> {
        return mapModel(T, isBasic: true)
    }
    
    public func mapListModel<T: Mappable>(_ listType: MappableListResponse<T>.Type, isBasic: Bool = false) -> ObservableResultAnyList<T> {
        return mapModel(listType, handle: { (dict) -> MappableListResponse<T>? in
            return listType.init(data: dict, isBasicMap: isBasic)
        }).flatMap({ (result) -> ObservableResultAnyList<T> in
            if let error = result.error {
                return .just(.failure(error))
            } else if let value = result.value {
                return .just(.success(value.transform(to: value.items)))
            }
            return .just(.failure(ResultError.create(with: .mapListModel)))
        })
    }
    
    public func basicMapListModel<T: Mappable>(_ listType: MappableListResponse<T>.Type) -> ObservableResultAnyList<T> {
        return mapListModel(listType, isBasic: true)
    }
    
    /// 判断请求状态码，返回成功或失败结果
    public func successCode(_ code: Int) -> ObservableResult<Bool> {
        return flatMap({ (apiResponse) -> ObservableResult<Bool> in
            guard let dataResponse = apiResponse.dataResponse, let response = dataResponse.response else {
                return .just(.failure(ResultError.create(with: .responseIsEmpty)))
            }
            return .just(.success(response.statusCode == code))
        })
    }
    
    /// 判断请求状态码，如果状态码通过，则继续往下进行
    public func filterCode(_ code: Int) -> Observable<Self.E> {
        
        return flatMap({ (apiResponse) -> Observable<Self.E> in
            if let dataResponse = apiResponse.dataResponse, let response = dataResponse.response {
                if response.statusCode != code {
                    apiResponse.error = ResultError.create(with: .filterCode(response.statusCode))
                }
            }
            return .just(apiResponse)
        })
    }
}

extension ObservableType {
    
    // 忽略网络的请求返回
    func withoutResponse(by disposeBag: DisposeBag) {
        self.subscribe({ _ in
        }).disposed(by: disposeBag)
    }
    
    // 忽略网络的请求返回，直接返回成功
    func ignoreResponse() -> ObservableResult<Bool> {
        let response = self.flatMap({ _ in ObservableResult<Bool>.just(.success(false)) })
        let ignore = ObservableResult<Bool>.just(.success(true))
        return Observable.merge([ignore, response])
            .flatMap({ (result) -> ObservableResult<Bool> in
                if let value = result.value, value {
                    return .just(.success(true))
                } else {
                    return .empty()
                }
            })
    }
}

public extension Result {
    
    public func transform<OtherType>(to data: OtherType?) -> Result<OtherType> {
        if let error = self.error {
            return .failure(error)
        } else if let data = data {
            return .success(data)
        }
        return .failure(ResultError.create(with: .resultTransform))
    }
    
    public func zip<OtherType>(with result: Result<OtherType>) -> Result<(Value, OtherType)> {
        if let error = self.error {
            return .failure(error)
        } else if let value = self.value {
            if let resultError = result.error {
                return .failure(resultError)
            } else if let resultValue = result.value {
                return .success((value, resultValue))
            }
        }
        return .failure(ResultError.create(with: .resultZip))
    }
}
