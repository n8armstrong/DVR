import Foundation

// There isn't a mutable NSHTTPURLResponse, so we have to make our own.
class URLHTTPResponse: HTTPURLResponse {

    // MARK: - Properties

    fileprivate var _URL: Foundation.URL?
    override var url: Foundation.URL? {
        get {
            return _URL ?? super.url
        }

        set {
            _URL = newValue
        }
    }

    fileprivate var _statusCode: Int?
    override var statusCode: Int {
        get {
            return _statusCode ?? super.statusCode
        }

        set {
            _statusCode = newValue
        }
    }

    fileprivate var _allHeaderFields: [AnyHashable: Any]?
    override var allHeaderFields: [AnyHashable: Any] {
        get {
            return _allHeaderFields ?? super.allHeaderFields
        }

        set {
            _allHeaderFields = newValue
        }
    }
}


extension HTTPURLResponse {
    override var dictionary: [String: AnyObject] {
        var dictionary = super.dictionary

        dictionary["headers"] = allHeaderFields as AnyObject?
        dictionary["status"] = statusCode as AnyObject?

        return dictionary
    }
}


extension URLHTTPResponse {
    convenience init?(dictionary: [String: AnyObject]) {
        guard let url = (dictionary["url"] as? String).flatMap(URL.init), let status = dictionary["status"] as? Int else {
            return nil
        }
        let headers = dictionary["headers"] as? [String: String]
        self.init(url: url, statusCode: status, httpVersion: nil, headerFields: headers)
    }
}
