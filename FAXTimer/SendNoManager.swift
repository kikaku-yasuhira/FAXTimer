import Foundation

class SendNoManager {
    var appData: AppData
    
    init(appData: AppData) {
        self.appData = appData
    }
    
    // sendnoを設定するメソッド
    func assignSendNumbers() {
        var currentSendNo = 1
        var firstStageCompleted = false  // 第一段階が完了したかを追跡するフラグ
        
        // Fトークンを持つ社員と、その後の順番を設定
        if let firstEmployeeIndex = appData.employees.firstIndex(where: { $0.fToken == "y" && $0.send == "y" }) {
            appData.employees[firstEmployeeIndex].sendno = String(currentSendNo)
            var currentEmployeeNo = appData.employees[firstEmployeeIndex].no  // 現在の基準番号
            print("Fトークンを持つ社員: \(appData.employees[firstEmployeeIndex].name), No: \(currentEmployeeNo), SendNo: \(currentSendNo)")
            currentSendNo += 1
            
            // Fトークン持ちの人物の後に、noが大きい人物に順番を割り振る
            while let nextEmployeeIndex = findNextEmployeeIndex(after: currentEmployeeNo, currentSendNo: currentSendNo) {
                appData.employees[nextEmployeeIndex].sendno = String(currentSendNo)
                currentEmployeeNo = appData.employees[nextEmployeeIndex].no  // 割り振られた社員のnoを基準に更新
                print("第一段階: 割り振られた社員: \(appData.employees[nextEmployeeIndex].name), No: \(currentEmployeeNo), SendNo: \(currentSendNo)")
                currentSendNo += 1
            }
            
            firstStageCompleted = true  // 第一段階が完了したことを記録
        } else {
            print("Fトークンを持つ社員が見つかりませんでした。")
            return
        }
        
        // 第二段階：第一段階が完了した後に実行
        if firstStageCompleted {
            print("第一段階が完了しました。第二段階を開始します。")
            // 残った社員に順番を割り振る
            while let nextEmployeeIndex = findNextEmployeeForSecondStage(currentSendNo: currentSendNo) {
                appData.employees[nextEmployeeIndex].sendno = String(currentSendNo)
                print("第二段階: 割り振られた社員: \(appData.employees[nextEmployeeIndex].name), No: \(appData.employees[nextEmployeeIndex].no), SendNo: \(currentSendNo)")
                currentSendNo += 1
            }
        }
        
        // 結果をログに出力
        logSendNoAssignments()
    }

    // 第一段階：次に送信する社員のインデックスを見つける
    private func findNextEmployeeIndex(after no: Int, currentSendNo: Int) -> Int? {
        var targetNo = no + 1  // 最初に現在の基準番号の1大きい値からスタート
        
        // nextIndexを見つけるまで、targetNoを1ずつ増加させて探索
        while let nextIndex = appData.employees.firstIndex(where: { $0.send == "y" && $0.sendno == "n" && $0.no == targetNo }) {
            print("第一段階: 次の社員候補: \(appData.employees[nextIndex].name), No: \(appData.employees[nextIndex].no)")
            return nextIndex
        }
        
        print("第一段階: 次の社員候補が見つかりませんでした。")
        return nil
    }
    
    // 第二段階：残った社員にsendnoを割り振る
    private func findNextEmployeeForSecondStage(currentSendNo: Int) -> Int? {
        // send=yかつsendno=nの中で一番小さいnoを持つ社員を探す
        let minNoEmployee = appData.employees.filter { $0.send == "y" && $0.sendno == "n" }.min(by: { $0.no < $1.no })
        let nextIndex = appData.employees.firstIndex(where: { $0.send == "y" && $0.sendno == "n" && $0.no == minNoEmployee?.no })
        
        if let index = nextIndex {
            print("第二段階: 次の社員候補: \(appData.employees[index].name), No: \(appData.employees[index].no)")
        } else {
            print("第二段階: 次の社員候補が見つかりませんでした。")
        }
        
        return nextIndex
    }
    
    // ログを出力するメソッド
    func logSendNoAssignments() {
        print("最終的な SendNo 割り当て:")
        for employee in appData.employees {
            print("Name: \(employee.name), No: \(employee.no), SendNo: \(employee.sendno)")
        }
    }
}
