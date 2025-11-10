import Foundation

struct EmployeeData: Identifiable, Codable {
    var id = UUID()
    var name: String
    var talkroomID: String
    var no: Int // 順番
    var send: String // "y" or "n"
    var fToken: String // "y" or "n"
    var sendno: String = "n" // 順番の送信状態 ("n" = 未送信, 数字 = 送信順)
}

class AppData: ObservableObject {
    @Published var employees: [EmployeeData] = []

    init() {
        loadData() // アプリ起動時に保存されたデータを読み込む
    }

    // データを追加
    func addEmployees(_ newEmployees: [EmployeeData]) {
        employees = newEmployees
        saveData() // データを追加したら自動的に保存
    }

    // データの保存（UserDefaultsなどを使用）
    func saveData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(employees)
            UserDefaults.standard.set(data, forKey: "savedEmployees")
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    // 保存されたデータの読み込み
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "savedEmployees") {
            do {
                let decoder = JSONDecoder()
                employees = try decoder.decode([EmployeeData].self, from: data)
            } catch {
                print("Failed to load data: \(error)")
            }
        }
    }

    // リセットボタンが押されたときにサーバーからデータを取得し、初期化する
    func resetData() {
        let fetcher = EmployeeDataFetcher()
        fetcher.fetchEmployees { [weak self] fetchedEmployees in
            self?.employees = fetchedEmployees
            self?.saveData() // 初期化後のデータを保存
        }
    }

    // SendNoの設定
    func updateSendNumbers() {
        let sendNoManager = SendNoManager(appData: self)
        sendNoManager.assignSendNumbers()
        self.saveData() // 更新後のデータを保存
    }

    // 全員のsendnoをnにリセットする
    func resetSendNumbers() {
        for index in employees.indices {
            employees[index].sendno = "n"
        }
        self.saveData() // リセット後のデータを保存
        logSendNoReset() // ログ出力
    }

    // SendNoリセット時のログ
    private func logSendNoReset() {
        print("SendNo Reset:")
        for employee in employees {
            print("Name: \(employee.name), SendNo: \(employee.sendno)")
        }
    }
}
