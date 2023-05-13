import Alamofire
import Foundation

class OpenAIApiClient {
    
    private let apiURL = "https://movie-script-generator.herokuapp.com/generate_script"
    
    func generateScript(prompts: [String], completion: @escaping (Result<String, Error>) -> Void) {
        
        let concatenatedPrompts = prompts.joined(separator: "\n")
        
        AF.request(apiURL,
                   method: .post,
                   parameters: ["prompt": concatenatedPrompts],
                   encoder: URLEncodedFormParameterEncoder.default)
            .responseDecodable(of: ScriptResponse.self) { response in
                switch response.result {
                case .success(let scriptResponse):
                    completion(.success(scriptResponse.script))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

struct ScriptResponse: Decodable {
    let script: String
}
