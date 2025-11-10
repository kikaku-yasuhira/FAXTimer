import Foundation

class EmployeeDataFetcher {
    func fetchEmployees(completion: @escaping ([EmployeeData]) -> Void) {
        // サーバーからデータを取得
        guard let url = URL(string: "http://192.168.0.245:8081/fax_timer") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                print("No data or failed to decode response")
                return
            }

            // HTMLをパースして、名前とトークルームIDを抽出
            var fetchedEmployees: [EmployeeData] = []
            
            let regex = try! NSRegularExpression(pattern: #"name="name" value="([^"]+)".*?name="talkroom_id" value="([^"]+)""#, options: .dotMatchesLineSeparators)
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
            
            for match in matches {
                if let nameRange = Range(match.range(at: 1), in: html),
                   let idRange = Range(match.range(at: 2), in: html) {
                    let name = String(html[nameRange])
                    let id = String(html[idRange])
                    fetchedEmployees.append(EmployeeData(name: name, talkroomID: id, no: 0, send: "y", fToken: "n"))
                }
            }
            
            DispatchQueue.main.async {
                completion(fetchedEmployees)
            }
        }

        task.resume()
    }
}
