import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

import harbour.sailfish_sinaweibo.sunrain 1.0

Page {
    id: weiboFavoritesPage

    property int _pageNum: 1

    property alias contentItem: lvUserWeibo

    function refresh() {
        modelWeibo.clear()

        _pageNum = 1
        _weiboFavorites(_pageNum)
    }

    function _addMore() {
        _pageNum++
        _weiboFavorites(_pageNum)
    }

    //////////////////////////////////////////////////////////////////         user status mentioned me
    function _weiboFavorites(page) {
        pullDownMenu.busy = true;
        var method = WeiboMethod.WBOPT_GET_FAVORITES;
        api.setWeiboAction(method, {'page':_pageNum});
    }

    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_FAVORITES) {
                var jsonObj = JSON.parse(replyData);
                for (var i=0; i<jsonObj.favorites.length; i++) {
                    modelWeibo.append( jsonObj.favorites[i] )
                }
                if (lvUserWeibo.model == undefined) {
                    lvUserWeibo.model = modelWeibo;
                }
                pullDownMenu.busy = false;
            }
        }
    }
    
//    Component.onCompleted: {
//        weiboFavoritesPage.refresh();
//    }

    SilicaListView{
        id: lvUserWeibo
        anchors.fill: parent
        cacheBuffer: 999999
        spacing: Theme.paddingSmall
//        model: modelWeibo
        footer: FooterLoadMore {
            visible: modelWeibo.count != 0
            onClicked: { weiboFavoritesPage._addMore();}
        }
        delegate: delegateWeibo
        header:PageHeader {
            id:pageHeader
            title: qsTr("Weibo Favorites")
        }
        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    weiboFavoritesPage.refresh();
                }
            }
        }
        ScrollDecorator{}
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
                    weiboJSONContent: modelWeibo.get(index).status
                    optionMenu: options
                    onRepostedWeiboClicked: {
                        pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                       {"userWeiboJSONContent":modelWeibo.get(index).status.retweeted_status})
                    }
                    onUsWeiboClicked: {
                        pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                       {"userWeiboJSONContent":modelWeibo.get(index).status})
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
                                           (model.status.retweeted_status == undefined || model.status.retweeted_status == "") == true ?
                                               "" :
                                               "//@"+model.status.user.name +": " + model.status.text ,
                                               false)
                            }
                        }
                        MenuItem {
                            text: qsTr("Comment")
                            onClicked: {
                                toSendPage("comment", {"id": model.status.id}, "", false)
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

    ListModel {
        id: modelWeibo
    }
}
