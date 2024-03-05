import Alamofire

struct APIError: Error, Decodable {
    let message: String?
    var code: Int?
    let errors: [String: String]?
    let errorCode: Int?
    var localizedDescription: String {
        let errorMessage = message ?? "Something went wrong please try again"
        return errorMessage
    }
}


class APIClient {
    static let shared = APIClient()
    let userCache = UserStorage()
    private let baseURL = AppConfiguration.apiBaseURL
    
    private init() {}
    
    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        return Session( configuration: configuration, interceptor: AuthInterceptor())
    }()
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let url = baseURL + endpoint
        let allHeaders = createHeaders(headers)
        sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: allHeaders)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    print("\n\n")
                    print("**************")
                    print(parameters ?? "")
                    print("\n")
                    print(error.localizedDescription)
                    print(String(describing: error))
                    print("**************")
                    print("\n\n")
                    guard let data = response.data, var apiError = try? JSONDecoder().decode(APIError.self, from: data)
                    else {
                        completion(.failure(error))
                        return;
                    }
                    if let statusCode = response.response?.statusCode{
                        apiError.code = statusCode
                    }
                    completion(.failure(apiError))
                }
            }
    }
    
    func requestWithImageFile<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .post,
        parameters: [String: Any] = [String: Any](),
        encoding: ParameterEncoding = JSONEncoding.default,
        file: Data?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let url = baseURL + endpoint
        let allHeaders = createHeaders(["Content-Type": "multipart/form-data"])
        sessionManager.upload(multipartFormData: {multipartFormData in
            if let file = file {
                multipartFormData.append(file, withName: "image",  fileName: "image.jpg", mimeType: "image/jpeg")
            }
            for (key,value) in parameters {
                if let value = value as? String{
                    multipartFormData.append(Data(value.utf8), withName: key)
                }
                
                if let array = value as? [String] {
                    for (index, value) in array.enumerated(){
                        let key = "\(key)[\(index)]"
                        let valueData = Data(value.utf8)
                        multipartFormData.append(valueData, withName: key)
                    }
                }
            }
        }, to: url, method: method, headers: allHeaders)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: T.self) { response in
            
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                print("\n\n")
                print("**************")
                print("\n")
                print(error.localizedDescription)
                print(String(describing: error))
                print("**************")
                print("\n\n")
                guard let data = response.data, var apiError = try? JSONDecoder().decode(APIError.self, from: data)
                else {
                    completion(.failure(error))
                    return
                }
                if let statusCode = response.response?.statusCode{
                    apiError.code = statusCode
                }
                completion(.failure(apiError))
            }
        }
        
    }
    
    
    private func createHeaders(_ additionalHeaders: HTTPHeaders?) -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Authorization": "Bearer \(AppConfiguration.getCurrentToken())",
            "Content-Type": "application/json"
        ]
        
        additionalHeaders?.forEach { headers[$0.name] = $0.value }
        
        return headers
    }
}

class AuthInterceptor : RequestInterceptor {
    let userCache = UserStorage()
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            userCache.remove()
        }
        completion(.doNotRetry)
    }
}
