//
//  iTunes_SearchTests.swift
//  iTunes SearchTests
//
//  Created by Craig Swanson on 2/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import XCTest
@testable import iTunes_Search

class iTunes_SearchTests: XCTestCase {

    func testSearchResultsSuccess() {
        
        let searchController = SearchResultController()
        
        let expectation = self.expectation(description: "Waiting for performSearch networking call")
        
        searchController.performSearch(for: "Facebook", resultType: .software, networkDependency: URLSession.shared) {
            // searchController.searchResults.count
            XCTAssert(searchController.searchResults.count > 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testSearchResultsAreInvalid() {
        let searchController = SearchResultController()
        
        let expectation = self.expectation(description: "Waiting for performSearch networking call")
        
        // Where is the file?
        let testingBundle = Bundle(for: iTunes_SearchTests.self)
        let bundleURL = testingBundle.url(forResource: "InvalidJSON", withExtension: "js")!
        
        // Get the contents of the file.
        let corruptedData = try! Data(contentsOf: bundleURL)
        
        // Pass along the invalid JSON to our mock session.
        let mockSession = MockDataSession(dataDependency: corruptedData)
        searchController.performSearch(for: "Facebook", resultType: .software, networkDependency: mockSession) {
            // searchController.searchResults.count
            XCTAssert(searchController.searchResults.count == 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testSearchResultsDataIsEmpty() {
        let searchController = SearchResultController()
        
        let expectation = self.expectation(description: "Waiting for performSearch networking call")
        
        let mockSession = MockDataSession(dataDependency: Data())
        searchController.performSearch(for: "Facebook", resultType: .software, networkDependency: mockSession) {
            // searchController.searchResults.count
            XCTAssert(searchController.searchResults.count == 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
