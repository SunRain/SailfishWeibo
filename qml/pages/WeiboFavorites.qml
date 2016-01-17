import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
//import "../js/Settings.js" as Settings
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
//        var method = WeiboMethod.WBOPT_GET_FAVORITES;
//        api.setWeiboAction(method, {"page":_pageNum});
        favorites.setParameters("page", _pageNum);
        favorites.getRequest();
    }

    function _removeFromFavorites(weiboId) {
        addNotification(qsTr("Removing from favorites"))
//        var method = WeiboMethod.WBOPT_POST_FAVORITES_DESTROY;
//        api.setWeiboAction(method, {"id":" "+weiboId+" "});
        favoritesDestroy.setParameters("id", weiboId);
        favoritesDestroy.postRequest();
    }
    Favorites {
        id: favorites
        onRequestAbort: {
            console.log("== favorites onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== favorites onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
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
    FavoritesDestroy {
        id: favoritesDestroy
        onRequestAbort: {
            console.log("== favoritesDestroy onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== favoritesDestroy onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            refresh();
        }
    }

//    Connections {
//        target: api
//        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
//        onWeiboPutSucceed: {
//            if (action == WeiboMethod.WBOPT_GET_FAVORITES) {
//                var jsonObj = JSON.parse(replyData);
//                for (var i=0; i<jsonObj.favorites.length; i++) {
//                    modelWeibo.append( jsonObj.favorites[i] )
//                }
//                if (lvUserWeibo.model == undefined) {
//                    lvUserWeibo.model = modelWeibo;
//                }
//                pullDownMenu.busy = false;
//            }
//            if (action == WeiboMethod.WBOPT_POST_FAVORITES_DESTROY) {
//                refresh();
//            }
//        }
//        onWeiboPutFail: {
//            if (action == WeiboMethod.WBOPT_POST_FAVORITES_DESTROY) {
//                addNotification(qsTr("Fail to remove from favorites"));
//            }
//        }
//    }
    
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
            width: parent.width
            spacing: Theme.paddingMedium
            WeiboCard {
                id:weiboCard
                width: parent.width - Theme.paddingMedium * 2
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingMedium
                }
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
                        text: qsTr("Remove from favorites")
                        onClicked: {
                            _removeFromFavorites(modelWeibo.get(index).status.id);
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
