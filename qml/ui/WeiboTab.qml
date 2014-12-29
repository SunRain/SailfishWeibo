import QtQuick 2.0
import "../components"
import Sailfish.Silica 1.0
import com.sunrain.sinaweibo 1.0

import "../js/Settings.js" as Settings

/*************************************************
  微博程序的首页以及微博条目展示列表
*************************************************/

SilicaListView {
    id: weiboTab
    property int _allWeiboPageNum: 1
    property int _groupWeiboPageNum: 1
    property string _groupIdstr: ""

    property bool _isGroupType: false

    function refresh() {
        showBusyIndicator();
        modelWeibo.clear();
        _allWeiboPageNum = 1;
        _isGroupType = false;
        var method = WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;
        api.setWeiboAction(method, {'page':_allWeiboPageNum,'access_token':Settings.getAccess_token()});
    }
    
    function addMore() {
        if(_isGroupType) {
            _groupWeiboPageNum++;
            var method = WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE;
            api.setWeiboAction(method, {
                                   "page":_groupWeiboPageNum,
                                   "access_token":Settings.getAccess_token(),
                                   "list_id":_groupIdstr});
        } else {
            _allWeiboPageNum++;
            var method = WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;
            api.setWeiboAction(method, {'page':_allWeiboPageNum,'access_token':Settings.getAccess_token()});
        }
    }

    function showAllWeibo() {
        refresh();
    }

    function showGroupWeibo(groupIdstr) {
        //        WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE, //获取某一好友分组的微博列表
        showBusyIndicator();
        modelWeibo.clear();
        _groupWeiboPageNum = 1;
        _groupIdstr = groupIdstr;
        _isGroupType = true;
        var method = WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE;
        api.setWeiboAction(method, {
                               "page":_groupWeiboPageNum,
                               "access_token":Settings.getAccess_token(),
                               "list_id":_groupIdstr});
    }


    ListModel {
        id: modelWeibo
    }
    
    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE
                    || action == WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE) {
                var jsonObj = JSON.parse(replyData);
                for (var i=0; i<jsonObj.statuses.length; i++) {
                    modelWeibo.append( {"JSON":jsonObj.statuses[i] })
                }
                if (weiboTab.model == undefined) {
                    weiboTab.model = modelWeibo;
                }
                stopBusyIndicator();
            }
        }
        onTokenExpired: {
            //            console.log("====== WeiboTab onTokenExpired value is "+ tokenExpired);
        }
    }

    cacheBuffer: 999999
    // model: modelWeibo
    footer: modelWeibo.count == 0 ? null : footerComponent
    delegate: delegateWeibo
    spacing: Theme.paddingSmall
    
    ScrollDecorator{}

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
                    weiboJSONContent: modelWeibo.get(index).JSON
                    optionMenu: options
                    onRepostedWeiboClicked: {
                        toWeiboPage(modelWeibo.get(index).JSON.retweeted_status);
                    }
                    onUsWeiboClicked: {
                        toWeiboPage(modelWeibo.get(index).JSON);
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
                                           (model.JSON.retweeted_status == undefined || model.JSON.retweeted_status == "") == true ?
                                               "" :
                                               "//@"+model.JSON.user.name +": " + model.JSON.text ,
                                               true)
                            }
                        }
                        MenuItem {
                            text: qsTr("Comment")
                            onClicked: {
                                toSendPage("comment", {"id": model.JSON.id}, "", true)
                            }
                        }
                    }
                }
            }
            Separator {
                width: parent.width
                color: Theme.highlightColor
            }
        }
    }
}
