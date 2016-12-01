import Foundation

struct Interaction {

    // MARK: - Properties

    let request: URLRequest
    let response: Foundation.URLResponse
    let responseData: Data?
    let recordedAt: Date


    // MARK: - Initializers

    init(request: URLRequest, response: Foundation.URLResponse, responseData: Data? = nil, recordedAt: Date = Date()) {
        self.request = request
        self.response = response
        self.responseData = responseData
        self.recordedAt = recordedAt
    }


    // MARK: - Encoding

    static func encodeBody(_ body: Data, headers: [String: String]? = nil) -> AnyObject? {
        if let contentType = headers?["Content-Type"] {
            // Text
            if contentType.hasPrefix("text/") {
                // TODO: Use text encoding if specified in headers
                return NSString(data: body, encoding: String.Encoding.utf8.rawValue)
            }

            // JSON
            if contentType.hasPrefix("application/json") {
                do {
                    return try JSONSerialization.jsonObject(with: body, options: []) as AnyObject
                } catch {
                    return nil
                }
            }
        }

        // Base64
        return body.base64EncodedString(options: []) as AnyObject?
    }

    static func dencodeBody(_ body: AnyObject?, headers: [String: String]? = nil) -> Data? {
        guard let body = body else { return nil }

        if let contentType = headers?["Content-Type"] {
            // Text
            if let string = body as? String, contentType.hasPrefix("text/") {
                // TODO: Use encoding if specified in headers
                return string.data(using: String.Encoding.utf8)
            }

            // JSON
            if contentType.hasPrefix("application/json") {
                do {
                    return try JSONSerialization.data(withJSONObject: body, options: [])
                } catch {
                    return nil
                }
            }
        }

        // Base64
        if let base64 = body as? String {
            return Data(base64Encoded: base64, options: [])
        }

        return nil
    }
}


extension Interaction {
    var dictionary: [String: AnyObject] {
        var dictionary: [String: AnyObject] = [
            "request": request.dictionary as AnyObject,
            "recorded_at": recordedAt.timeIntervalSince1970 as AnyObject
        ]

        var response = self.response.dictionary
        if let data = responseData, let body = Interaction.encodeBody(data, headers: response["headers"] as? [String: String]) {
            response["body"] = body
        }
        dictionary["response"] = response as AnyObject?

        return dictionary
    }

    init?(dictionary: [String: AnyObject]) {
        guard let requestDictionary = dictionary["request"] as? [String: AnyObject],
            let request = URLRequest.urlRequest(dictionary: requestDictionary),
            let responseDictionary = dictionary["response"] as? [String: AnyObject],
            let response = URLHTTPResponse(dictionary: responseDictionary),
            let recordedAt = dictionary["recorded_at"] as? Int else {
                print("got nil")
                return nil
        }

        print("got here")
        self.response = response
        self.request = request
        self.recordedAt = Date(timeIntervalSince1970: TimeInterval(recordedAt))
        self.responseData = Interaction.dencodeBody(responseDictionary["body"], headers: responseDictionary["headers"] as? [String: String])
    }
}
