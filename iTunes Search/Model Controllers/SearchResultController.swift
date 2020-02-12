//
//  SearchResultController.swift
//  iTunes Search
//
//  Created by Spencer Curtis on 8/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class SearchResultController {
    
    func performSearch(for searchTerm: String,
                       resultType: ResultType,
                       networkDependency: iTunesSearchSession,
                       completion: @escaping () -> Void) {
        
        // Building the URL components.
        // Dependencies:
        // 1. A baseURL (that's not in the parameters)
        // 2. Parameter keys are hardcoded.
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let parameters = ["term": searchTerm,
                          "entity": resultType.rawValue]
        let queryItems = parameters.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents?.queryItems = queryItems
        
        // Putting them all together, and making sure a URL exists.
        guard let requestURL = urlComponents?.url else { return }

        // Passing the URL to the URLRequest.
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        // Handing the data off to the networking layer (URLSession).
        // Single Responsibility Principle: Perform Search
        // 1. Build the Components
        // 2. Build the URL Request
        // 3. Perform the network request
        
        // Test how this function behaves when it gets passed along invalid data.
        // Who owns this data? -> URLSession
        // Who do we want to be the owner of this data? -> iTunesSearchTests
        //
        // We want a function that both URLSession and iTunesSearchTests share.
        networkDependency.performiTunesSearch(request: request) { possibleReceivedData in
            
            guard let receivedData = possibleReceivedData else {
                completion()
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let searchResults = try jsonDecoder.decode(SearchResults.self, from: receivedData)
                self.searchResults = searchResults.results
                completion()
            } catch {
                print("Unable to decode data into object of type [SearchResult]: \(error)")
                completion()
            }
        }
    }
    
    let baseURL = URL(string: "https://itunes.apple.com/search")!
    var searchResults: [SearchResult] = []
}

protocol iTunesSearchSession {
    func performiTunesSearch(request: URLRequest, completion: @escaping (Data?) -> Void)
}

extension URLSession : iTunesSearchSession {
    
    func performiTunesSearch(request: URLRequest, completion: @escaping (Data?) -> Void) {
        let iTunesSearchTask = dataTask(with: request) { (data, _, error) in
            
            if let error = error { NSLog("Error fetching data: \(error)") }
            guard let data = data else {
                completion(nil)
                return
            }
            
            completion(data)
        }
        
        iTunesSearchTask.resume()
    }
}

class MockDataSession : iTunesSearchSession {
    
    var dataDependency: Data
    init(dataDependency: Data) {
        self.dataDependency = dataDependency
    }
    
    // Mocking empty data.
    func performiTunesSearch(request: URLRequest, completion: @escaping (Data?) -> Void) {
        completion(self.dataDependency)
    }
}
