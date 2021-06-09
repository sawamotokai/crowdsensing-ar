//
//  File.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-07.
//

import Foundation

// hubeny's distance formula
/**
 * ２地点間の距離(m)を求める
 * ヒュベニの公式から求めるバージョン
 *
 * @param float $lat1 latitude1
 * @param float $lon1 longitude1
 * @param float $lat2 latitude2
 * @param float $lon2 longitude2
 * @return float distance(m)
 */
func coord2distMeter(current: (la: Double, lo: Double), target: (la: Double, lo: Double)) -> Double {
    // 緯度経度をラジアンに変換
    let currentLa   = current.la * Double.pi / 180
    let currentLo   = current.lo * Double.pi / 180
    let targetLa    = target.la * Double.pi / 180
    let targetLo    = target.lo * Double.pi / 180
    
    // 緯度差
    let radLatDiff = currentLa - targetLa
    
    // 経度差算
    let radLonDiff = currentLo - targetLo
    
    // 平均緯度
    let radLatAve = (currentLa + targetLa) / 2.0
    
    // 測地系による値の違い
    // 赤道半径
    let a = 6378137.0
    
    // 極半径
    let b = 6356752.314140356

    // 第一離心率^2
    let e2 = (a * a - b * b) / (a * a)
    
    // 赤道上の子午線曲率半径
    let a1e2 = a * (1 - e2)
    
    let sinLat = sin(radLatAve);
    let w2 = 1.0 - e2 * (sinLat * sinLat);
    
    // 子午線曲率半径m
    let m = a1e2 / (sqrt(w2) * w2);
    
    // 卯酉線曲率半径 n
    let n = a / sqrt(w2)
    
    // 算出
    let t1 = m * radLatDiff
    let t2 = n * cos(radLatAve) * radLonDiff
    let distance = sqrt((t1 * t1) + (t2 * t2))
    return distance / 1000
}
