import Foundation

class MessageSender {
    static func sendMessage(talkroomID: String, message: String, completion: @escaping (Bool, Error?) -> Void) {
        // SettingsManager から Bot ID とサーバーアドレスを取得
        let botID = SettingsManager.shared.getBotID()

        // talkroomIDをURLエンコード
        let encodedTalkroomID = talkroomID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? talkroomID

        // APIのURLを構築
        guard let url = URL(string: "https://www.worksapis.com/v1.0/bots/\(botID)/users/\(encodedTalkroomID)/messages") else {
            print("Error: 無効なURL")
            completion(false, NSError(domain: "InvalidURL", code: 1, userInfo: nil))
            return
        }

        // アクセストークンを取得してからメッセージ送信
        SettingsManager.shared.fetchAccessToken { accessToken, error in
            if let error = error {
                print("Error: トークンの取得に失敗しました - \(error.localizedDescription)")
                completion(false, error)
                return
            }

            guard let accessToken = accessToken else {
                print("Error: トークンがnilです")
                completion(false, NSError(domain: "TokenError", code: 2, userInfo: nil))
                return
            }

            print("トークン取得成功: \(accessToken)")

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // 送信するメッセージの内容
            let messageContent: [String: Any] = [
                "content": [
                    "type": "text",
                    "text": message // 実際に送信するメッセージを設定
                ]
            ]

            // JSONに変換
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: messageContent, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error: メッセージコンテンツのJSON変換に失敗しました")
                completion(false, error)
                return
            }

            // リクエストの詳細をログ出力
            print("リクエストURL: \(url)")
            print("リクエストヘッダー: \(request.allHTTPHeaderFields ?? [:])")
            print("リクエストボディ: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "No body")")

            // APIリクエストを送信
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: APIリクエストが失敗しました - \(error.localizedDescription)")
                    completion(false, error)
                    return
                }

                // レスポンスをログ出力
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTPステータスコード: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                        let responseError = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP status code: \(httpResponse.statusCode)"])
                        print("Error: メッセージ送信に失敗しました - HTTP status code: \(httpResponse.statusCode)")
                        completion(false, responseError)
                        return
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("レスポンス: \(responseString)")
                }

                print("メッセージ送信成功: TalkroomID: \(talkroomID), Message: \(message)")
                completion(true, nil) // メッセージ送信成功
            }

            task.resume()
        }
    }
}
