import Foundation
import Alamofire

class OpenAIApiClient {
    private let apiKey = "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"
    
    func generateScript(prompts: [String], completion: @escaping (Result<String, AFError>) -> Void) {
        var previousResponses = [String]()
        let dispatchGroup = DispatchGroup()
        
        for prompt in prompts {
            dispatchGroup.enter()
            
            let input = (previousResponses + [prompt]).joined(separator: "\n")
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(apiKey)"
            ]
            
            let parameters: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "prompt": input,
                "max_tokens": 500
            ]
            
            AF.request("https://api.openai.com/v1/engines/davinci-codex/completions",
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: headers)
            .responseDecodable(of: OpenAIResponse.self) { response in
                switch response.result {
                case .success(let value):
                    previousResponses.append(value.choices[0].text.trimmingCharacters(in: .whitespacesAndNewlines))
                case .failure(let error):
                    completion(.failure(error))
                    dispatchGroup.leave()
                    return
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(previousResponses.last ?? ""))
        }
    }
}
