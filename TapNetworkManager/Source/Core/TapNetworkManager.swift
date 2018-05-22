//
//  TapNetworkManager.swift
//  TapNetworkManager/Core
//
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import struct Foundation.NSData.Data
import struct Foundation.NSURL.URL
import struct Foundation.NSURLRequest.URLRequest
import class Foundation.NSURLResponse.URLResponse
import class Foundation.NSURLSession.URLSession
import class Foundation.NSURLSession.URLSessionConfiguration
import class Foundation.NSURLSession.URLSessionDataTask

/// Network Manager class.
public class TapNetworkManager {

    // MARK: - Public -

    public typealias RequestCompletionClosure = (URLSessionDataTask?, Any?, Error?) -> Void

    // MARK: Properties

    /// Defines if request logging enabled.
    public static var isRequestLoggingEnabled = false
    
    /// Base URL.
    public private(set) var baseURL: URL

    // MARK: Methods

    /// Creates an instance of TapNetworkManager with the base URL and session configuration.
    public required init(baseURL: URL, configuration: URLSessionConfiguration = .default) {

        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
    }

    /// Performs request operation and calls completion when request finishes.
    ///
    /// - Parameters:
    ///   - operation: Network request operation.
    ///   - completion: Completion closure that is called when request finishes.
    public func performRequest(_ operation: TapNetworkRequestOperation, completion: RequestCompletionClosure?) {

        var request: URLRequest
        do {

            request = try self.createURLRequest(from: operation)

            if type(of: self).isRequestLoggingEnabled {
                
                self.log(request)
            }
            
            var dataTask: URLSessionDataTask?
            let dataTaskCompletion: (Data?, URLResponse?, Error?) -> Void = { [weak self] (data, response, anError) in

                if TapNetworkManager.isRequestLoggingEnabled {
                    
                    self?.log(response, data: data, serializationType: operation.responseType)
                    self?.log(anError)
                }
                
                if let d = data {

                    do {

                        let responseObject = try TapSerializer.deserialize(d, with: operation.responseType)
                        completion?(dataTask, responseObject, anError)

                    } catch {

                        completion?(dataTask, nil, error)
                    }

                } else {

                    completion?(dataTask, nil, anError)
                }
            }

            let task = self.session.dataTask(with: request, completionHandler: dataTaskCompletion)
            dataTask = task
            task.resume()

        } catch {

            completion?(nil, nil, error)
        }
    }

    // MARK: - Private -

    private struct Constants {

        fileprivate static let contentTypeHeaderName = "Content-Type"
        fileprivate static let jsonContentTypeHeaderValue = "application/json"
        fileprivate static let plistContentTypeHeaderValue = "application/x-plist"

        @available(*, unavailable) private init() {}
    }

    // MARK: Properties

    private var session: URLSession

    // MARK: Methods

    private func createURLRequest(from operation: TapNetworkRequestOperation) throws -> URLRequest {

        let url = try self.prepareFullRequestURL(for: operation)
        var request = URLRequest(url: url)
        request.httpMethod = operation.httpMethod.rawValue

        for (headerField, headerValue) in operation.additionalHeaders {

            if request.value(forHTTPHeaderField: headerField) == nil {

                request.addValue(headerValue, forHTTPHeaderField: headerField)
            }
        }

        if let bodyModel = operation.bodyModel {

            guard bodyModel.serializationType != .url else {

                throw TapNetworkError.serializationError(.wrongData)
            }

            request.httpBody = try TapSerializer.serialize(bodyModel.body, with: bodyModel.serializationType) as? Data

            if request.value(forHTTPHeaderField: Constants.contentTypeHeaderName) == nil {

                let value = self.requestContentTypeHeaderValue(for: bodyModel.serializationType)
                request.setValue(value, forHTTPHeaderField: Constants.contentTypeHeaderName)
            }
        }

        return request
    }

    private func prepareFullRequestURL(for operation: TapNetworkRequestOperation) throws -> URL {

        var relativePath: String

        if let urlModel = operation.urlModel {

            guard let serializedQuery = try TapSerializer.serialize(urlModel, with: .url) as? String else {

                throw TapNetworkError.serializationError(.wrongData)
            }

            relativePath = operation.path + serializedQuery

        } else {

            relativePath = operation.path
        }

        guard let resultingURL = URL(string: relativePath, relativeTo: self.baseURL)?.absoluteURL else {

            throw TapNetworkError.wrongURL(self.baseURL.absoluteString + relativePath)
        }

        return resultingURL
    }

    private func requestContentTypeHeaderValue(for dataType: TapSerializationType) -> String {

        switch dataType {

        case .json:

            return Constants.jsonContentTypeHeaderValue

        case .propertyList:

            return Constants.plistContentTypeHeaderValue

        default: return ""
        }
    }
    
    private func log(_ request: URLRequest, serializationType: TapSerializationType? = nil) {
        
        print("Request:\n---------------------")
        print("\(request.httpMethod ?? "nil") \(request.url?.absoluteString ?? "nil")")
        
        self.log(request.allHTTPHeaderFields)
        self.log(request.httpBody, serializationType: serializationType)
        
        print("---------------------------")
    }
    
    private func log(_ response: URLResponse?, data: Data?, serializationType: TapSerializationType? = nil) {
        
        guard let nonnullResponse = response else { return }
        
        print("Response:\n---------------------")
        
        if let url = nonnullResponse.url {
            
            print("URL: \(url.absoluteString)")
        }
        
        guard let httpResponse = nonnullResponse as? HTTPURLResponse else {
            
            print("------------------------")
            return
        }
        
        print("HTTP status code: \(httpResponse.statusCode)")
        
        self.log(httpResponse.allHeaderFields)
        self.log(data, serializationType: serializationType)
        
        print("------------------------")
    }
    
    private func log(_ error: Error?) {
        
        guard let nonnullError = error else { return }
        print("Error: \(nonnullError)")
    }
    
    private func log(_ headerFields: [AnyHashable: Any]?) {
        
        guard let nonnullHeaderFields = headerFields, nonnullHeaderFields.count > 0 else { return }
        
        let headersString = (nonnullHeaderFields.map { "\($0.key): \($0.value)" }).joined(separator: "\n")
        print("Headers:\n\(headersString)")
    }
    
    private func log(_ data: Data?, serializationType: TapSerializationType? = nil) {
        
        guard let body = data, let type = serializationType, let object = try? TapSerializer.deserialize(body, with: type) else { return }
        
        var jsonWritingOptions: JSONSerialization.WritingOptions
        if #available(iOS 11.0, *) {
            
            jsonWritingOptions = [.prettyPrinted, .sortedKeys]
            
        } else {
            
            jsonWritingOptions = [.prettyPrinted]
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: object, options: jsonWritingOptions),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            
            print("Body:\n\(jsonString)")
        }
    }
}
