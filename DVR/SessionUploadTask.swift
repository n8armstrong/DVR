class SessionUploadTask: URLSessionUploadTask {

    // MARK: - Types

    typealias Completion = (Data?, Foundation.URLResponse?, NSError?) -> Void

    // MARK: - Properties

    weak var session: Session!
    let request: URLRequest
    let completion: Completion?
    var dataTask: SessionDataTask!

    override var response: Foundation.URLResponse? {
        return dataTask.interaction?.response
    }

    override var taskIdentifier: Int {
        return dataTask.taskIdentifier
    }

    // MARK: - Initializers

    init(session: Session, request: URLRequest, completion: Completion? = nil) {
        self.session = session
        self.request = request
        self.completion = completion
        super.init()
        dataTask = SessionDataTask(session: session, request: request, backingTask: self, completion: completion)
    }

    // MARK: - NSURLSessionTask

    override func cancel() {
        // Don't do anything
    }

    override func resume() {
        dataTask.resume()
    }
}
