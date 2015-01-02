import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

import harbour.sailfish_sinaweibo.sunrain 1.0

Page {
    id: weiboMentionedPage

    property var uid
    property string userName: ""
    property int _pageNum: 1

    property alias contentItem: lvUserWeibo

    function refresh() {
        modelWeibo.clear()

        _pageNum = 1
        _weiboMentioned(_pageNum)
    }

    function _addMore() {
        _pageNum++
        _weiboMentioned(_pageNum)
    }

    //////////////////////////////////////////////////////////////////         user status mentioned me
    function _weiboMentioned(page) {
        showBusyIndicator();

        var method = WeiboMethod.WBOPT_GET_STATUSES_MENTIONS;
        api.setWeiboAction(method, {'page':_pageNum});
    }

    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_STATUSES_MENTIONS) {
                var jsonObj = JSON.parse(replyData);
                for (var i=0; i<jsonObj.statuses.length; i++) {
                    modelWeibo.append( jsonObj.statuses[i] )
                }
                if (lvUserWeibo.model == undefined) {
                    lvUserWeibo.model = modelWeibo;
                }
                stopBusyIndicator();
            }
        }
    }
    
//    Component.onCompleted: {
//        weiboMentionedPage.refresh();
//    }

    ListView{
        id: lvUserWeibo
        anchors.fill: parent
        cacheBuffer: 999999
//        model: modelWeibo
        footer: FooterLoadMore {
            visible: modelWeibo.count != 0
            onClicked: { weiboMentionedPage._addMore();}
        }
        delegate: delegateWeibo
        header:PageHeader {
            id:pageHeader
            title: qsTr("Weibo mentioned me")
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    weiboMentionedPage.refresh();
                }
            }
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
                        pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                       {"userWeiboJSONContent":modelWeibo.get(index).retweeted_status})
                    }
                    onUsWeiboClicked: {
                        pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                       {"userWeiboJSONContent":modelWeibo.get(index)})
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
                                               false)
                            }
                        }
                        MenuItem {
                            text: qsTr("Comment")
                            onClicked: {
                                toSendPage("comment", {"id": model.id}, "", false)                        
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

    ListModel {
        id: modelWeibo
    }
}
