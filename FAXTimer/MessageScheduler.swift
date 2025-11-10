import Foundation

class MessageScheduler {
    private var timer: Timer?
    private var currentSendNo = 1 // 現在の送信順
    private var isRunning = false // スケジューラーが実行中かどうかのフラグ
    private let appData: AppData // AppDataから社員データを取得
    private var accessToken: String // アクセストークン
    private var completion: (() -> Void)? // 完了時のコールバック

    init(appData: AppData, accessToken: String, completion: @escaping () -> Void) {
        self.appData = appData
        self.accessToken = accessToken
        self.completion = completion
    }

    // スケジューラーをスタートする
    func start() {
        guard !isRunning else {
            print("Scheduler is already running.")
            return // 実行中の場合は何もせず終了
        }
        
        isRunning = true
        currentSendNo = 1 // 送信番号をリセット
        print("メッセージスケジューラーが開始されました。")
        
        // まずは全員にタイマー開始のメッセージを送信
        sendInitialMessageToAll { [weak self] in
            // sendNo = 1の社員に送信開始
            self?.sendNextMessage()
        }
        
        // 15分ごとに次の社員に送信
        timer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.sendNextMessage()
        }
    }

    // 全員にタイマー開始メッセージを送信
    private func sendInitialMessageToAll(completion: @escaping () -> Void) {
        let sortedEmployees = appData.employees.filter { $0.send == "y" }.sorted { $0.sendno < $1.sendno }
        let sortedNames = sortedEmployees.map { "\($0.name)さん" }.joined(separator: "\n")
        let initialMessage = """
        📠タイマーがスタートしました！📠
        今日の順番は、
        \(sortedNames)
        です！
        タイマーを止める時はアプリでStopボタンを押してくださいね😊
        """

        var remainingMessages = sortedEmployees.count
        
        for employee in sortedEmployees {
            MessageSender.sendMessage(talkroomID: employee.talkroomID, message: initialMessage) { success, error in
                if success {
                    print("初期メッセージが送信されました \(employee.name)")
                } else if let error = error {
                    print("初期メッセージの送信に失敗しました \(employee.name): \(error.localizedDescription)")
                }

                remainingMessages -= 1
                if remainingMessages == 0 {
                    completion() // 全てのメッセージ送信が完了した後に次に進む
                }
            }
        }
    }

    // 次のメッセージを送信
    private func sendNextMessage() {
        if let employee = appData.employees.first(where: { $0.sendno == "\(currentSendNo)" }) {
            let nextEmployeeName = getNextEmployeeName()
            let message = """
            📠仕分けをお願いします！📠
            \(employee.name)さん、FAXの仕分けをお願いします。
            15分後に\(nextEmployeeName)さんにお知らせします。
            
            タイマーを止める際はアプリからStopボタンを押してください😊
            """
            print("送信中: \(employee.name), TalkroomID: \(employee.talkroomID), SendNo: \(employee.sendno)")

            MessageSender.sendMessage(talkroomID: employee.talkroomID, message: message) { success, error in
                if success {
                    print("メッセージが正常に送信されました \(employee.name)")
                } else if let error = error {
                    print("メッセージ送信に失敗しました \(employee.name): \(error.localizedDescription)")
                }
            }
            
            currentSendNo += 1 // 次の送信番号へ
        } else {
            // 全員に送信が完了したらループして最初に戻る
            currentSendNo = 1
            print("sendNo 1から再開します。")
        }
    }

    // 次の送信者の名前を取得
    private func getNextEmployeeName() -> String {
        let nextSendNo = currentSendNo + 1
        if let nextEmployee = appData.employees.first(where: { $0.sendno == "\(nextSendNo)" }) {
            return nextEmployee.name
        } else if let firstEmployee = appData.employees.first(where: { $0.sendno == "1" }) {
            return firstEmployee.name
        } else {
            return "次の送信者なし"
        }
    }

    // スケジューラーを停止（手動のみ）
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        resetSendNumbers()
        print("メッセージスケジューラーが停止し、sendNoがリセットされました。")
        
        // 送信をyに設定した全員に停止メッセージを送信
        sendStopMessageToAll()
    }

    // タイマー停止メッセージを全員に送信
    private func sendStopMessageToAll() {
        let sortedEmployees = appData.employees.filter { $0.send == "y" }
        let stopMessage = """
        ⏰タイマーを停止しました⏰
        Stopボタンが押されました。
        皆様、お疲れ様でした😌
        """

        for employee in sortedEmployees {
            MessageSender.sendMessage(talkroomID: employee.talkroomID, message: stopMessage) { success, error in
                if success {
                    print("停止メッセージが送信されました \(employee.name)")
                } else if let error = error {
                    print("停止メッセージの送信に失敗しました \(employee.name): \(error.localizedDescription)")
                }
            }
        }
    }

    // 全員のsendNoをnにリセット
    private func resetSendNumbers() {
        for index in appData.employees.indices {
            appData.employees[index].sendno = "n"
        }
        appData.saveData()
        logSendNoReset()
    }

    // リセット時のログ出力
    private func logSendNoReset() {
        print("SendNoがリセットされました。")
        for employee in appData.employees {
            print("Name: \(employee.name), SendNo: \(employee.sendno)")
        }
    }
}
