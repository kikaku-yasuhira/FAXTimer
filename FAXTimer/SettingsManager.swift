import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    
    // Bot ID
    private let botID = "8788230"
    
    // アクセストークン取得用のサーバーアドレス
    private let serverAddress = "http://192.168.0.245:8080/token"
    
    // Bot IDを取得するメソッド
    func getBotID() -> String {
        return botID
    }
    
    // サーバーアドレスを取得するメソッド
    func getServerAddress() -> String {
        return serverAddress
    }
    
    // アクセストークンを取得するメソッド
    func fetchAccessToken(completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: serverAddress) else {
            completion(nil, NSError(domain: "Invalid URL", code: 400, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data,
                  let htmlString = String(data: data, encoding: .utf8),
                  let token = self.extractToken(from: htmlString) else {
                completion(nil, NSError(domain: "Invalid response", code: 500, userInfo: nil))
                return
            }
            
            completion(token, nil)
        }
        
        task.resume()
    }
    
    // HTMLからアクセストークンを抽出するメソッド
    private func extractToken(from html: String) -> String? {
        // 正規表現を使って<div class="token-box">の内容を抽出
        let pattern = "<div class=\"token-box\">(.*?)</div>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        
        let range = NSRange(location: 0, length: html.utf16.count)
        if let match = regex.firstMatch(in: html, options: [], range: range) {
            if let tokenRange = Range(match.range(at: 1), in: html) {
                return String(html[tokenRange])
            }
        }
        return nil
    }
}
