import SwiftUI

struct SendSetting1View: View {
    @ObservedObject var appData: AppData // 親から渡されたappDataを使用

    var body: some View {
        ZStack {
            Color("YMTgray").edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("お休みの人は「送らない」にしてください。")
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
                            ForEach(appData.employees) { employee in
                                HStack {
                                    Text(employee.name)
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .frame(width: 150, alignment: .leading)

                                    // 送信設定のスイッチ
                                    Toggle(isOn: Binding(
                                        get: {
                                            employee.send == "y"
                                        },
                                        set: { newValue in
                                            if let index = appData.employees.firstIndex(where: { $0.id == employee.id }) {
                                                appData.employees[index].send = newValue ? "y" : "n"
                                            }
                                        }
                                    )) {
                                        Text(employee.send == "y" ? "送る" : "送らない")
                                            .foregroundColor(.white)
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: Color("YMTred")))
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
                    appData.saveData() // sendの状態を保存
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
    }
}
