//
//  ApptentiveXCTests.swift
//  ApptentiveTests
//
//  Created by Apptentive on 2/21/20.
//  Copyright © 2020 Frank Schmitt. All rights reserved.
//

import Foundation
import XCTest
@testable import Apptentive

/*
 
 1) Make feature test real (URL now depedancy, swap mocks with real, use actual service or GO mock server)
 2) extract header keys to struct for SST
 3) seperate tests into own files
 
 */

class AuthenticationFeatureTest: XCTestCase {
    
    func testSDKRegistrationSucceedsWithPositiveConfirmation() {
        let credentials = Apptentive.Credentials(key: "valid", signature: "valid")
        
        self.sdkRegistrationWithConfirmation(credentials: credentials) {
            XCTAssertTrue($0)
        }
    }
    
    func testSDKRegistrationFailsWithNegativeConfirmation() {
        let credentials = Apptentive.Credentials(key: "", signature: "")
        
        self.sdkRegistrationWithConfirmation(credentials: credentials) {
            XCTAssertFalse($0)
        }
    }
    
    func sdkRegistrationWithConfirmation(credentials: Apptentive.Credentials, asserts: @escaping (Bool)->()) {
        let url = URL(string: "https://bdd-api-default.k8s.dev.apptentive.com/conversations")!
        let authenticator = ApptentiveAuthenticator(url: url, requestor: URLSession.shared)
        
        let expectation = self.expectation(description: "test")
        
		Apptentive(authenticator: authenticator).register(credentials: credentials) { success in
            asserts(success)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10.0)
    }
}

class AuthenticatorTests: XCTestCase {
	func testBuildHeaders() {
		let credentials = Apptentive.Credentials(key: "123", signature: "abc")
		let expectedHeaders = [
			"APPTENTIVE-KEY": "123",
			"APPTENTIVE-SIGNATURE": "abc"
		]

		let headers = ApptentiveAuthenticator.buildHeaders(credentials: credentials)

		XCTAssertEqual(headers, expectedHeaders)
	}

	func testBuildsARequest() {
		let url = URL(string: "https://example.com")!
		let headers = ["Foo": "Bar"]
		let method = "BAZ"

		let request = ApptentiveAuthenticator.buildRequest(url: url, method: method, headers: headers)

		XCTAssertEqual(request.url, url)
		XCTAssertEqual(request.allHTTPHeaderFields, headers)
		XCTAssertEqual(request.httpMethod, method)
	}

	func testMaps201ResponseToSuccess() {
		let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 201, httpVersion: nil, headerFields: nil)

		let result = ApptentiveAuthenticator.processResponse(response: response)

		XCTAssertTrue(result)
	}

	func testMaps401ResponseToFailure() {
		let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)

		let result = ApptentiveAuthenticator.processResponse(response: response)

		XCTAssertFalse(result)
	}

	func testMapsNoResponseToFailure() {
		let response: URLResponse? = nil

		let result = ApptentiveAuthenticator.processResponse(response: response)

		XCTAssertFalse(result)
	}

	func testAuthenticate() {
        let url = URL(string: "http://example.com")!
		let requestor = SpyRequestor()
        
        let authenticator = ApptentiveAuthenticator(url: url, requestor: requestor)
		let credentials = Apptentive.Credentials(key: "", signature: "")

		let expectation = XCTestExpectation()
		authenticator.authenticate(credentials: credentials) { (success) in

			XCTAssertNotNil(requestor.request)
			XCTAssertEqual(requestor.request?.allHTTPHeaderFields?.isEmpty, false)
            XCTAssertEqual(requestor.request?.url, url)
			XCTAssertEqual(requestor.request?.httpMethod, "POST")
			XCTAssert(success || !success)

			expectation.fulfill()
		}

        class SpyRequestor: HTTPRequesting {
            var request: URLRequest?

            func sendRequest(_ request: URLRequest, completion: @escaping (URLResult) -> ()) {
                self.request = request

                let stubReponse = HTTPURLResponse()
                completion((nil, stubReponse, nil))
            }
        }
	}
}
