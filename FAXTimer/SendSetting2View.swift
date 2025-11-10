import SwiftUI

struct SendSetting2View: View {
    @ObservedObject var appData: AppData // 親から渡されたappDataを使用
    @State private var selectedEmployeeID: UUID? = nil // 選択された社員IDを保持

    var body: some View {
        ZStack {
            Color("YMTgray").edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("最初に送る人を決めてください。")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding()

                if appData.employees.isEmpty {
                    Text("データがありません")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(appData.employees.filter { $0.send == "y" }) { employee in
                                Button(action: {
                                    selectFirstToken(for: employee.id)
                                }) {
                                    Text(employee.name)
                                        .font(.system(size: 20))
                                        .foregroundColor(employee.fToken == "y" ? .yellow : .white) // fTokenの状態に基づいて色を変更
                                        .frame(width: 200, alignment: .leading)
                                }
                                .padding()
                                .background(Color("YMTsubgray"))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxHeight: 400) // スクロールエリアの制限
                }

                // Saveボタン
                Button(action: {
                    appData.saveData() // Fトークンの状態を保存
                }) {
                    Text("Save")
                        .font(.system(size: 25, weight: .bold))
                        .padding()
                        .frame(width: 150, height: 50)
                        .background(Color("YMTred"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .onAppear {
            // 初期ロード時にfTokenがyの社員を選択状態に設定
            if let firstTokenEmployee = appData.employees.first(where: { $0.fToken == "y" }) {
                selectedEmployeeID = firstTokenEmployee.id
            }
        }
    }

    // Fトークンを選択された社員に設定
    private func selectFirstToken(for employeeID: UUID) {
        // 既存のFトークン保持者がいた場合、それをリセット
        if let currentFirstTokenIndex = appData.employees.firstIndex(where: { $0.fToken == "y" }) {
            appData.employees[currentFirstTokenIndex].fToken = "n"
        }

        // 新たに選択された社員のfTokenをyに設定
        if let index = appData.employees.firstIndex(where: { $0.id == employeeID }) {
            appData.employees[index].fToken = "y"
            selectedEmployeeID = employeeID
        }
    }
}
