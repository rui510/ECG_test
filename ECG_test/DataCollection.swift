//
//  DataCollection.swift
//  HackdayApp
//
//  Created by Ken Honda on 2019/12/09.
//  Copyright © 2019 Ken Honda. All rights reserved.
//

import SwiftUI
import HealthKit


struct DataCollection: View {
    // @Stateを使ってUIの状態と同期をとる
    @State var labelText = "Tap Here"
    @State var flag = false
    //HealthKitのデータを格納するHealthStoreを定義
    let healthStore = HKHealthStore()
    // アクセス許可が欲しいデータタイプを指定
    let allTypes = Set([
        HKSampleType.quantityType(forIdentifier: .stepCount)!,
    ])
    
    let type = HKObjectType.quantityType(forIdentifier: .stepCount)!  // allTypeとは別にtypeを定義
    var calendar = Calendar.current  // カレンダーを取得

//今回は歩数のみ
    
    var body: some View {

        // 縦にViewを並べる
        VStack() {
            Text(labelText)
                .font(.largeTitle)
                .padding(.bottom)
            // ボタンの作成(フラグを使って表示されるテキストを変える)
            Button(action: {
                // ボタンがタップされてない時
                if(self.flag){
                    self.labelText = "Get Data"
                    self.flag = false
                }else{
                    // ボタンがタップされた時
                    // もしHealthKitが利用可能なら
                    if HKHealthStore.isHealthDataAvailable() {
                        self.labelText = "HealthKit Available"
                        self.healthStore.requestAuthorization(toShare: nil, read: self.allTypes) { (success, error) in}
                            let date = Date()  // 今日の日付を取得
                            let yesterday = self.calendar.date(byAdding: .day, value: -1, to: date)  // "昨日"は上で定義したカレンダーを使って計算する
                                // 取得するデータの開始(きのう)と終わり(きょう)を入れる
                            let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: date)
                            var step = 0.0  // 結果を格納するための変数
                        let query = HKStatisticsQuery(quantityType: self.type, quantitySamplePredicate: predicate, options:.cumulativeSum){query, result, error in
                            let query_result = result?.sumQuantity() as Any
                            
                            
                            
                            
                            step = (query_result as AnyObject).doubleValue(for: HKUnit.count())  // HKQuantity型をdoubleに変換
                            
                            
                            
                            
                            print(step)  // コンソールに出力
                            self.labelText = String(step) + "歩" // 文字列に変換してデバイスに表示
                        }
                        
                        self.healthStore.execute(query)
                        
                    }else{
                        
                        self.labelText = "Unavailable"}
                    self.flag = true
                
                }}){
                    // ボタンのテキスト
                    Text("Button")
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                }
            .padding(.all)
            .background(Color.blue)
        }
    }
}
// インスタンスの生成
struct DataCollection_Previews: PreviewProvider {
    static var previews: some View {
        DataCollection()
    }
}
