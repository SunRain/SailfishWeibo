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
    
//    property alias menus:lvHomeWeibo.pullDownMenu //lvHomeWeiboPullDownMenu //._content
//    property alias header: lvHomeWeibo.header
    
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
                var jsonObj = JSON.parse(replyData);
                for (var i=0; i<jsonObj.statuses.length; i++) {
                    modelWeibo.append( jsonObj.statuses[i] )
                }
                if (lvHomeWeibo.model == undefined) {
                    lvHomeWeibo.model = modelWeibo;
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
        
        header: PageHeader {
            id:pageHeader
            title: qsTr("Sailfish Weibo")
        }

        PullDownMenu {
            id:lvHomeWeiboPullDownMenu
            MenuItem {
                text: qsTr("Logout")
                onClicked: {
                    weiboLogout();
                    pageStack.popAttached(undefined, PageStackAction.Animated);
                    reset();
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    weiboTab.refresh();
                }
            }
            MenuItem {
                text: qsTr("New")
                onClicked: {
                    weiboTab.gotoSendNewWeibo();
                }
            }
        }
        
        cacheBuffer: 999999
       // model: modelWeibo
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
        Column {
            anchors{left:parent.left; right:parent.right }
            spacing: Theme.paddingMedium
            
            Item {
                anchors{left:parent.left; right:parent.right; }
                height: childrenRect.height
                WeiboCard {
                    id:weiboCard
                    weiboJSONContent: modelWeibo.get(index)
                    optionMenu: options
                    onRepostedWeiboClicked: {
                        toWeiboPage(modelWeibo.get(index).retweeted_status/*, "-100"*/);
                    }
                    onUsWeiboClicked: {
                        toWeiboPage(/*modelWeibo, index*/modelWeibo.get(index));
                    }
                    onAvatarHeaderClicked: {
                        toUserPage(userId);
                    }
                    onLabelLinkClicked: {
                        Qt.openUrlExternally(link);
                    }
                    onLabelImageClicked: {
                        toGalleryPage(modelImages, index);
                    }
                    ContextMenu {
                        id:options
                        MenuItem {
                            text: qsTr("Repost")
                            onClicked: {
                                toSendPage("repost", {"id": model.id}, 
                                           (model.retweeted_status == undefined || model.retweeted_status == "") == true ?
                                               "" :
                                               "//@"+model.user.name +": " + model.text ,
                                               true)
                            }
                        }
                        MenuItem {
                            text: qsTr("Comment")
                            onClicked: {
                                toSendPage("comment", {"id": model.id}, "", true)                        
                            }
                        }
                    }
                }
            }
            Separator {
                width: parent.width
                color: Theme.highlightColor
            }
            Item {
                width: parent.width
                height: Theme.paddingSmall
            }
        }
    }

}
