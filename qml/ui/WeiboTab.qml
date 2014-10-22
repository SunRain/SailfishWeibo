import QtQuick 2.0
import "../components"
import Sailfish.Silica 1.0
import com.sunrain.sinaweibo 1.0

import "../js/Settings.js" as Settings

/*************************************************
  微博程序的首页以及微博条目展示列表
*************************************************/

Item {
    id: weiboTab
    //anchors.fill: parent
    //title: qsTr("Weibo")
    //clip : true
    
    property int pageNum: 1
    //property int actionMethod
    property bool isRefresh: false
    
    property alias menus: lvHomeWeiboPullDownMenu._content
    property alias header: lvHomeWeibo.header
    
    signal sendNewWeibo
    
    function refresh() {
        showBusyIndicator();
        
        modelWeibo.clear()
        pageNum = 1
        isRefresh = true
        var method = WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;
        api.setWeiboAction(method, {'page':pageNum,'access_token':Settings.getAccess_token()});
    }
    
    function addMore() {
        pageNum++
        var method = WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;
        api.setWeiboAction(method, {'page':pageNum,'access_token':Settings.getAccess_token()});
    }
    
    function gotoSendNewWeibo() {
        weiboTab.sendNewWeibo();
    }
    
    ListModel {
        id: modelWeibo
    }
    
    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE) {
                var json = JSON.parse(replyData);
                for (var i=0; i<json.statuses.length; i++) {
                    modelWeibo.append( json.statuses[i] )
                }
                stopBusyIndicator();
            }
        }
        onTokenExpired: {
//            console.log("====== WeiboTab onTokenExpired value is "+ tokenExpired);
        }
    }
    
    SilicaListView{
        id: lvHomeWeibo
        width: weiboTab.width 
        height: weiboTab.height
        
        PullDownMenu {
            id:lvHomeWeiboPullDownMenu
        }
        
        cacheBuffer: 999999
        model: modelWeibo
        footer: modelWeibo.count == 0 ? null : footerComponent
        delegate: delegateWeibo
        
    }
    
    Component {
        id: footerComponent
        FooterLoadMore {
            onClicked: {weiboTab.addMore();}
        }
    }
    
    Component {
        id: delegateWeibo
        
        DelegateWeibo {
            //            onClicked: {
            //                console.log("WeiboTab === weibo Detail:" + JSON.stringify(modelWeibo.get(index)))
            //                toWeiboPage(modelWeibo, index)
            //            }
            onUsWeiboClicked: {
                console.log("WeiboTab === onUsWeiboClicked");
                toWeiboPage(modelWeibo, index);
            }
            onRepostedWeiboClicked: {
                //TODO MagicNumber
                toWeiboPage(modelWeibo.get(index).retweeted_status, "-100");
            }
        }
    }
}
