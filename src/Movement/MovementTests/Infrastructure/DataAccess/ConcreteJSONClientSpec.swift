import Foundation
import Quick
import Nimble
import CBGPromise

@testable import Movement

class ConcreteJSONClientSpec : QuickSpec {
    var subject: ConcreteJSONClient!
    var jsonSerializationProvider : FakeNSJSONSerializationProvider!
    var urlSession : FakeNSURLSession!

    override func spec() {
        describe("ConcreteJSONClient") {
            beforeEach {
                self.jsonSerializationProvider = FakeNSJSONSerializationProvider()
                self.urlSession = FakeNSURLSession()

                self.subject = ConcreteJSONClient(
                    urlSession: self.urlSession,
                    jsonSerializationProvider: self.jsonSerializationProvider
                )
            }

            describe("fetching some JSON with a given URL, method and data") {
                let expectedURL = NSURL(string: "https://example.com/berrniieee")!
                let expectedMethod = "POST"
                let expectedBodyDictionary = ["some": "data"]
                var future: JSONFuture!

                context("when the given data can be serialized to JSON") {
                    beforeEach {
                        future = self.subject.JSONPromiseWithURL(expectedURL,
                            method: expectedMethod,
                            bodyDictionary: expectedBodyDictionary)
                    }

                    it("creates a task from the session by constructing a request") {
                        let request = self.urlSession.lastRequest

                        expect(request.URL).to(equal(expectedURL))
                        expect(request.HTTPMethod).to(equal("POST"))
                        let serializedDictionary = self.jsonSerializationProvider.lastReceivedObjectToConvertToData as! NSDictionary
                        expect(serializedDictionary).to(equal(expectedBodyDictionary))
                        expect(request.HTTPBody).to(beIdenticalTo(self.jsonSerializationProvider.returnedData))
                    }

                    it("resumes the task") {
                        expect(self.urlSession.lastReturnedTask.resumeCalled).to(beTrue())
                    }

                    context("when the task completes without an error") {
                        let expectedData = NSData()

                        context("with a status code of 200") {
                            let response = NSHTTPURLResponse(URL: expectedURL, statusCode: 200, HTTPVersion: "1.1", headerFields: nil)

                            describe("parsing the JSON") {
                                it("attempts to parse the received data") {
                                    self.urlSession.lastCompletionHandler!(expectedData, response!, nil)

                                    expect(self.jsonSerializationProvider.lastReceivedData).to(beIdenticalTo(expectedData))
                                }
                            }

                            context("when JSON parsing succeeds") {
                                it("resolves the promise with the JSON document") {
                                    self.urlSession.lastCompletionHandler!(expectedData, response!, nil)

                                    let expectedValue = self.jsonSerializationProvider.returnedJSON
                                    let value : NSDictionary! = (future.value as! NSDictionary)
                                    expect(value).to(beIdenticalTo(expectedValue))
                                }
                            }

                            context("when JSON parsing fails") {
                                it("rejects the promise with an error") {
                                    self.jsonSerializationProvider.enableDecodingError = true
                                    self.urlSession.lastCompletionHandler!(expectedData, response!, nil)

                                    switch(future.error!) {
                                    case JSONClientError.JSONDeserializationError(let error, let data):
                                        expect(error).to(beIdenticalTo(self.jsonSerializationProvider.returnedError))
                                        expect(data).to(beIdenticalTo(expectedData))
                                    default:
                                        fail("Unexpected error type")
                                    }
                                }
                            }
                        }

                        context("with a non-200 status code") {
                            let response = NSHTTPURLResponse(URL: expectedURL, statusCode: 400, HTTPVersion: "1.1", headerFields: nil)

                            it("rejects the promise with an error") {
                                self.urlSession.lastCompletionHandler!(expectedData, response!, nil)
                                switch(future.error!) {
                                case JSONClientError.HTTPStatusCodeError(let statusCode, let data):
                                    expect(statusCode).to(equal(400))
                                    expect(data).to(beIdenticalTo(expectedData))
                                default:
                                    fail("Unexpected error type")
                                }
                            }
                        }

                        context("with a wrong response type") {
                            it("rejects the promise with an error") {
                                let badResponse = NSURLResponse()
                                self.urlSession.lastCompletionHandler!(expectedData, badResponse, nil)

                                switch(future.error!) {
                                case JSONClientError.NotAnHTTPResponseError(let receivedResponse):
                                    expect(receivedResponse).to(beIdenticalTo(badResponse))
                                default:
                                    fail("Unexpected error type")
                                }

                            }
                        }
                    }

                    context("when the task completes with an error") {
                        it("rejects the promise with the network error") {
                            let expectedError = NSError(domain: "some domain", code: 0, userInfo: nil)
                            self.urlSession.lastCompletionHandler!(nil, nil, expectedError)

                            switch(future.error!) {
                            case JSONClientError.NetworkError(let error):
                                expect(error).to(beIdenticalTo(expectedError))
                            default:
                                fail("Unexpected error type")
                            }
                        }
                    }
                }

                context("when the given data cannot be serialized to JSON") {
                    beforeEach {
                        self.jsonSerializationProvider.enableEncodingError = true

                        future = self.subject.JSONPromiseWithURL(expectedURL,
                            method: expectedMethod,
                            bodyDictionary: expectedBodyDictionary)
                    }

                    it("rejects the promise with the serialization error") {
                        switch(future.error!) {
                        case JSONClientError.BodySerializationError(let error):
                            expect(error).to(beIdenticalTo(self.jsonSerializationProvider.returnedError))
                        default:
                            fail("Unexpected error type")
                        }
                    }

                    it("does not attempt to make a request") {
                        expect(self.urlSession.lastRequest).to(beNil())
                        expect(self.urlSession.lastURL).to(beNil())
                    }
                }
            }
        }
    }
}

class FakeNSJSONSerializationProvider : NSJSONSerializationProvider {
    var enableDecodingError : Bool = false
    var enableEncodingError : Bool = false
    let returnedData = "{\"some\": \"data\"}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    let returnedJSON = NSDictionary()
    let returnedError = NSError(domain: "errrr", code: 123, userInfo: nil)
    var lastReceivedObjectToConvertToData : AnyObject!
    var lastReceivedData : NSData!
    var lastReceivedReadingOptions : NSJSONReadingOptions!
    var lastReceivedWritingOptions : NSJSONWritingOptions!

    override func jsonObjectWithData(data: NSData, options opt: NSJSONReadingOptions) throws -> AnyObject {
        self.lastReceivedData = data
        self.lastReceivedReadingOptions = opt

        if(enableDecodingError) {
            throw returnedError
        } else {
            return self.returnedJSON
        }
    }

    override func dataWithJSONObject(obj: AnyObject, options opt: NSJSONWritingOptions) throws -> NSData {
        let error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        self.lastReceivedObjectToConvertToData = obj
        self.lastReceivedWritingOptions = opt

        if(enableEncodingError) {
            throw returnedError
        } else {
            if let value = self.returnedData {
                return value
            }
            throw error
        }
    }
}
