//
//  APIManagerTest.swift
//  YuvkaTests
//
//  Created by Mustafa Bekirov on 07.12.2024.
//

import XCTest
@testable import Yuvka

// this will perform mock networking
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Request handler is not set.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

final class APIManagerTest: XCTestCase {
    
    var urlSession: URLSession!
    var apiManager: APIManager!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        apiManager = APIManager(urlSession: urlSession)
    }
    
    override func tearDown() {
        apiManager = nil
        super.tearDown()
    }
    
    func testFetchRecipeInfo() async {
        
        /*
         Model
         let id: Int
         let title: String
         let image: String
         let dishTypes: [String]
         let servings: Int
         let readyInMinutes: Int
         let summary: String
         */
        
        let jsonResponse = """
        {
            "results": [
                {
                    "id": 123,
                    "title": "Test Recipe",
                    "image": "testingImageUrl",
                    "dishTypes": ["Dinner"],
                    "servings": 12,
                    "readyInMinutes": 12,
                    "summary": "Sample Test Recipe"
                }
            ]
        }
        """
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil)!
            return (response, jsonResponse.data(using: .utf8))
        }
        
        do {
            let data = try await apiManager
                .fetchRecipesInfo(
                    query: "Chicken",
                    numberOfRes: 1,
                    searchMethod: .SearchByName
                ).results
            
            // Assertions
            XCTAssertEqual(data[0].id, 123)
            XCTAssertEqual(data[0].title, "Test Recipe")
            XCTAssertEqual(data[0].summary, "Sample Test Recipe")
            XCTAssertEqual(data[0].dishTypes[0], "Dinner")
            XCTAssertEqual(data[0].servings, 12)
            XCTAssertEqual(data[0].readyInMinutes, 12)
        } catch {
            XCTFail("Fetch failed with error: \(error)")
        }
    }
}
