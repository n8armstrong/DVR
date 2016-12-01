import Foundation

extension URLRequest {
    var dictionary: [String: AnyObject] {
        var dictionary = [String: AnyObject]()

        if let method = httpMethod {
            dictionary["method"] = method as AnyObject?
        }

        if let url = url?.absoluteString {
            dictionary["url"] = url as AnyObject?
        }

        if let headers = allHTTPHeaderFields {
            dictionary["headers"] = headers as AnyObject?
        }

        if let data = httpBody, let body = Interaction.encodeBody(data, headers: allHTTPHeaderFields) {
            dictionary["body"] = body
        }

        return dictionary
    }
}


extension URLRequest {
    mutating func requestByAppendingHeaders(_ headers: [AnyHashable: Any]) -> URLRequest {
        appendHeaders(headers)
        return self
    }

    mutating func requestWithBody(_ body: Data) -> URLRequest {
        httpBody = body
        return self
    }
}


extension URLRequest {
    static func urlRequest(dictionary: [String: AnyObject]) -> URLRequest? {
        guard let string = dictionary["url"] as? String, let url = URL(string: string) else {
            return nil
        }
        var request = URLRequest(url: url)

        if let method = dictionary["method"] as? String {
            request.httpMethod = method
        }


        if let headers = dictionary["headers"] as? [String: String] {
            request.allHTTPHeaderFields = headers
        }

        if let body = dictionary["body"] {
            request.httpBody = Interaction.dencodeBody(body, headers: request.allHTTPHeaderFields)
        }

        return request
    }
}


extension URLRequest {
    mutating func appendHeaders(_ headers: [AnyHashable: Any]) {
        var existingHeaders = allHTTPHeaderFields ?? [:]

        headers.forEach { header in
            guard let key = header.0 as? String, let value = header.1 as? String, existingHeaders[key] == nil else {
                return
            }

            existingHeaders[key] = value
        }

        allHTTPHeaderFields = existingHeaders
    }
}
