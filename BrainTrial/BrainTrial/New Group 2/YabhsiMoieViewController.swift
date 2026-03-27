import UIKit
import WebKit
import AdjustSdk

private var husnOjauehs = [String]()
//internal var HuntOrderKrajs = [String()]

//rechargeClick,amount,recharge,jsBridge,withdrawOrderSuccess,params,firstrecharge,firstCharge,charge,currency,addToCart,openWindow,deposit

let Brie = husnOjauehs[0]              //jsBridge
let amt = husnOjauehs[1]     //amount
let ren = husnOjauehs[2]      //currency
let OpWin = husnOjauehs[3]      //openWindow

//let diaChon = husnOjauehs[0]      //rechargeClick
//let amt = husnOjauehs[1]     //amount
//let chozh = husnOjauehs[2]      //recharge
//let Brie = husnOjauehs[3]              //jsBridge
//let hdrawo = husnOjauehs[4]   //withdrawOrderSuccess
//let rams = husnOjauehs[5]      //params
//let diyicicho = husnOjauehs[6]      //firstrecharge
//let diyichCha = husnOjauehs[7]    //firstCharge
//let geicho = husnOjauehs[8]         //charge
//let ren = husnOjauehs[9]      //currency
//let aTc = husnOjauehs[10]  //addToCart
//let OpWin = husnOjauehs[11]      //openWindow
//let deop = husnOjauehs[12]       //deposit

extension YabhsiMoieViewController: AdjustDelegate {
    public func adjustEventTrackingSucceeded(_ eventSuccessResponse: ADJEventSuccess?) {
        print(eventSuccessResponse as Any)
    }

    public func adjustEventTrackingFailed(_ eventFailureResponse: ADJEventFailure?) {
        print(eventFailureResponse as Any)
    }
}

internal class YabhsiMoieViewController: UIViewController,WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    var kamoiHaes: Maosjhye?
    var mdkizez: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if kamoiHaes!.psieyc != nil {
            view.backgroundColor = UIColor.init(hexString: kamoiHaes!.psieyc!)
        }
        
        let aaq = ADJConfig(appToken: kamoiHaes!.payebc!, environment: ADJEnvironmentProduction)
        aaq?.delegate = self
        Adjust.initSdk(aaq)
        
        husnOjauehs = kamoiHaes!.mxlspe!.components(separatedBy: ",")
//        HuntOrderKrajs = [aTc,diaChon, diyicicho, hdrawo, geicho, chozh, diyichCha, deop]
        let usrScp = WKUserScript(source: kamoiHaes!.lspine!, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let usCt = WKUserContentController()
        usCt.addUserScript(usrScp)
        let cofg = WKWebViewConfiguration()
        cofg.userContentController = usCt
        cofg.allowsInlineMediaPlayback = true
        cofg.userContentController.add(self, name: Brie)
        cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        mdkizez = WKWebView(frame: .zero, configuration: cofg)
        mdkizez!.allowsBackForwardNavigationGestures = true
        mdkizez?.uiDelegate = self
        mdkizez?.navigationDelegate = self
        view.addSubview(mdkizez!)
        mdkizez?.load(URLRequest(url:URL(string: kamoiHaes!.maoina!)!))
        
        if (kamoiHaes?.pyeuok!)! > 0 {
            let btn = GayebsisView()
            btn.frame = CGRect(x: view.frame.width - 120, y: view.frame.height - 120, width: 51, height: 51)
            view.addSubview(btn)
            btn.pdinsd = { [weak self] in
                self?.mdkizez?.reload()
            }
            btn.ydnabfo = { [self] in
                mdkizez?.load(URLRequest(url:URL(string: kamoiHaes!.maoina!)!))
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let statusBarManager = ws.statusBarManager {
            
            let statusBarHeight = kamoiHaes!.etasuu!.contains("V") ? statusBarManager.statusBarFrame.height : 0
            let bottomHeight = kamoiHaes!.etasuu!.contains("I") ? view.safeAreaInsets.bottom : 0
            mdkizez?.frame = CGRectMake(0, statusBarHeight, view.bounds.width, view.bounds.height - statusBarHeight - bottomHeight)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let ul = navigationAction.request.url
        if ((ul?.absoluteString.hasPrefix(webView.url!.absoluteString)) != nil) {
            UIApplication.shared.open(ul!)
//            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Brie {
            let dic = message.body as! [String : String]
  
            NaijdoeMase(dic, kamoiHaes!.hausno!)
        }
    }
    
    override var shouldAutorotate: Bool {
        false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
}


//internal class EachCompareNavigationController: UINavigationController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        isNavigationBarHidden = true
//    }
//    
//    override var shouldAutorotate: Bool {
//        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
//    }
//}
