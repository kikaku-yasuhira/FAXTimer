import SwiftUI

struct ContentView: View {
    @ObservedObject var appData = AppData() // AppDataを保持
    @State private var isSending = false // 送信状態の管理

    var body: some View {
        NavigationStack {
            ZStack {
                Color("YMTgray").edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 30) {
                        // タイトル
                        Text("Welcome to\nFAXTimer!!")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .padding()

                        // メンバー設定ボタン
                        NavigationLink(destination: MemberSettingsView(appData: appData)) {
                            Text("初期設定")
                                .font(.system(size: 25, weight: .medium))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color("YMTred"))
                                .cornerRadius(8)
                        }

                        // 送信先設定①
                        NavigationLink(destination: SendSetting1View(appData: appData)) {
                            Text("送信先設定①")
                                .font(.system(size: 25, weight: .medium))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color("YMTred"))
                                .cornerRadius(8)
                        }

                        // 送信先設定②
                        NavigationLink(destination: SendSetting2View(appData: appData)) {
                            Text("送信先設定②")
                                .font(.system(size: 25, weight: .medium))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color("YMTred"))
                                .cornerRadius(8)
                        }

                        // 横並びに配置するためにHStackを使用
                        HStack(spacing: 30) {
                            // Startボタン
                            Button(action: {
                                // SendNoを割り振る
                                let sendNoManager = SendNoManager(appData: appData)
                                sendNoManager.assignSendNumbers()

                                // サーバーにデータを送信
                                startMessageScheduler()
                            }) {
                                Text("Start")
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 140, height: 50)
                                    .background(isSending ? Color.gray : Color("YMTred"))
                                    .cornerRadius(8)
                            }
                            .disabled(isSending)

                            // Stopボタン
                            Button(action: {
                                stopMessageScheduler()
                            }) {
                                Text("Stop")
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 140, height: 50)
                                    .background(isSending ? Color("YMTsubgray") : Color.gray)
                                    .cornerRadius(8)
                            }
                            .disabled(!isSending)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // サーバーにEmployeeDataを送信
    private func startMessageScheduler() {
        // サーバーのURLをポート8082に修正
        let url = URL(string: "http://192.168.0.245:8082/fax_timer")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // EmployeeDataをJSON形式に変換
        let employeeData = appData.employees
        guard let jsonData = try? JSONEncoder().encode(employeeData) else {
            print("Failed to encode employee data.")
            return
        }

        // サーバーにデータを送信
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                print("Failed to send data: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No valid response from server.")
                return
            }
            print("Response status code: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 {
                print("EmployeeData successfully sent to server.")
                DispatchQueue.main.async {
                    isSending = true // 送信成功後にフラグを設定
                }
            } else {
                print("Server returned an error: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response from server: \(responseString)")
                }
            }
        }

        task.resume()
    }

    // 停止処理
    private func stopMessageScheduler() {
        // サーバーにストップリクエストを送信
        let url = URL(string: "http://192.168.0.245:8082/stop_scheduler")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send stop request: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No valid response from server.")
                return
            }
            print("Response status code: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 {
                print("Scheduler successfully stopped on server.")
                DispatchQueue.main.async {
                    isSending = false // 停止後にフラグをリセット
                }
            } else {
                print("Server returned an error: \(httpResponse.statusCode)")
            }
        }

        task.resume()

        // EmployeeDataのsendnoをリセット
        for index in appData.employees.indices {
            appData.employees[index].sendno = "n"
        }
        appData.saveData() // データの保存

        isSending = false
    }
}
