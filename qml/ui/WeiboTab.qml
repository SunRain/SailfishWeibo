import QtQuick 2.0
//import Ubuntu.Components 0.1
import "../components"
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import Sailfish.Silica 1.0
import com.sunrain.sinaweibo 1.0

/*************************************************
  微博程序的首页以及微博条目展示列表
*************************************************/

Item {
    id: weiboTab
    //anchors.fill: parent
    //title: qsTr("Weibo")
    //clip : true
    
    property int pageNum: 1
    property int actionMethod
    property bool isRefresh: false

    property alias menus: lvHomeWeiboPullDownMenu._content
    property alias header: lvHomeWeibo.header
    
    signal sendNewWeibo

    function refresh() {
        showBusyIndicator();
        
        // TODO refresh all weibo
        modelWeibo.clear()
//        for (var i=0; i<result.statuses.length; i++) {
//            modelWeibo.append( result.statuses[i] )
//        }
        pageNum = 1
        isRefresh = true
        //homeStatus(Settings.getAccess_token(), pageNum)
        //actionMethod = weibomethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;
        var method = WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;
                //weiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;

        console.log(" for method "+ method);
        
        api.setWeiboAction(method, {'page':pageNum});
    }

    function addMore() {
        pageNum++
        //homeStatus(Settings.getAccess_token(), pageNum)
        api.setWeiboAction(method, {'page':pageNum});
    }

    function gotoSendNewWeibo() {
        weiboTab.sendNewWeibo();
    }

    //////////////////////////////////////////////////////////////////         home status
    function homeStatus(token, page)
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
//                          console.log("status length: ", result.statuses.length)
//                          console.log("status 0:", JSON.stringify(result.statuses[0]))
                        //                        if (page == 1) mainView.refreshHome(result)
                        if (isRefresh) {
                            isRefresh = false
                        }
                        for (var i=0; i<result.statuses.length; i++) {
                            modelWeibo.append( result.statuses[i] )
                        }
                    }
                }else{
                    // TODO  empty result
                    console.log("weiboTab === homeStatus error");
                }
                stopBusyIndicator();
            }
        }
        
        WB.weiboHomeStatus(token, page, new observer())
    }
    
    ListModel {
        id: modelWeibo
    }

    Connections {
        target: api
        //weiboPutSucceed(const QString& replyData);
        onWeiboPutSucceed: {
            var json = JSON.parse(replyData);
            for (var i=0; i<json.statuses.length; i++) {
                modelWeibo.append( json.statuses[i] )
            }
            stopBusyIndicator();
        }
    }

    // Tell SilicaFlickable the height of its content.
   // contentHeight: column.height
    
//    Column{
//        id: column
        
//        spacing: Theme.paddingSmall 
        SilicaListView{
            id: lvHomeWeibo
            width: weiboTab.width 
            height: weiboTab.height

            PullDownMenu {
                id:lvHomeWeiboPullDownMenu
            }

            //contentHeight: parent.height * count
            
            cacheBuffer: 999999/*height * 2*/
            //spacing: Theme.paddingMedium
            model: modelWeibo
            footer: modelWeibo.count == 0 ? null : footerComponent
            delegate: delegateWeibo
            
        }
        
//        VerticalScrollDecorator { flickable: lvHomeWeibo }
//    }
        
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
                //TODO 添加方法
                console.log("WeiboTab === onRepostedWeiboClicked");
//                console.log("******" +JSON.stringify(modelWeibo.get(index).retweeted_status));

                //TODO MagicNumber
                toWeiboPage(modelWeibo.get(index).retweeted_status, "-100");
            }
        }
    }
    
//    Component {
//        id: footerWeibo
        
//        Item {
//            width: lvHomeWeibo.width
//            height: Theme.itemSizeMedium
//            Button {
//                anchors.centerIn: parent
//                text: qsTr("click here to load more..")
//                onClicked: {
//                    weiboTab.addMore();
//                }
//            }
//        }
//    }
}
