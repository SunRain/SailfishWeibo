import QtQuick 2.0
import "./weiboapi.js" as WB
import "../js/Settings.js" as Settings

QtObject {
    id: weiboApiHandler
    
    signal tokenExpired(bool isExpired)
    signal logined
    signal sendedWeibo
    signal getComments
    
    //////////////////////////////////////////////////////////////////         login
    function login(id, secret, code)
    {
        function observer() {}
        observer.prototype = {
            update: function(status, result)
            {
                if(status != "error"){
                    if(result.error) {
                        // TODO  error handler
                    }else {
                        // right result
                        console.log("access_token: ", result.access_token)
                        Settings.setAccess_token(result.access_token)
                        Settings.setUid(result.uid)
                        logined()
                    }
                }else{
                    // TODO  empty result
                }
            }
        }
        
        WB.weiboGetAccessCode(id, secret, code, new observer())
    }
    
    //////////////////////////////////////////////////////////////////         check token
    function checkToken(token)
    {
        function observer() {}
        observer.prototype = {
            update: function(status, result)
            {
                if (status == "no_network") {
                    mainView.addNotification(i18n.tr("Opps, Something wrong with the network ?"), 99)
                }
                
                if(result != undefined){
                    if(result.error_code != undefined) {
                        // TODO  error handler
                        if (result.error_code == 21314
                                || result.error_code == 21315
                                || result.error_code == 21316
                                || result.error_code == 21317
                                || result.error_code == 21327
                                ) {
                            tokenExpired(true)
                        }
                    }else {
                        // right result
                        console.log("token: ", Settings.getAccess_token())
                        if (result.expire_in < 1) {
                            tokenExpired(true)
                        }
                        else {
                            tokenExpired(false)
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }
        
        WB.weiboCheckToken(token, new observer())
    }
    
    
    
    
}
