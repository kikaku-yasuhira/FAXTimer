import SwiftUI

struct MemberSettingsView: View {
    @ObservedObject var appData: AppData // 親から渡されたappDataを使用

    var body: some View {
        ZStack {
            Color("YMTgray").edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("順番を決めてください。")
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

                                    // 順番を編集可能にするテキストフィールド
                                    TextField("No", value: $appData.employees[appData.employees.firstIndex(where: { $0.id == employee.id })!].no, formatter: NumberFormatter())
                                        .padding(10) // 内側の余白
                                        .background(Color.white) // 背景色を白に
                                        .cornerRadius(5) // 角を丸く
                                        .foregroundColor(.black) // 文字色を黒に
                                        .frame(width: 50)
                                }
                                .padding()
                                .background(Color("YMTsubgray")) // 背景を指定
                                .cornerRadius(8) // 角を丸く
                            }
                        }
                    }
                    .frame(maxHeight: 400) // スクロールエリアの制限
                }

                HStack(spacing: 20) {
                    // Saveボタン
                    Button(action: {
                        appData.saveData() // noなどを保存
                    }) {
                        Text("Save")
                            .font(.system(size: 25, weight: .bold))
                            .padding()
                            .frame(width: 150, height: 50)
                            .background(Color("YMTred"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    // Resetボタン
                    Button(action: {
                        appData.resetData() // サーバーからデータを取得してリセット
                    }) {
                        Text("Reset")
                            .font(.system(size: 25, weight: .bold))
                            .padding()
                            .frame(width: 150, height: 50)
                            .background(Color("YMTsubgray"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}
