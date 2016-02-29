import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

WBPage {
    id: weiboFavoritesPage

    property int _pageNum: 1

//    property alias contentItem: lvUserWeibo

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
        favorites.setParameters("page", _pageNum);
        if (tokenProvider.useHackLogin) {
            console.log("=== weiboFavoritesPage containerid "+userMeObject.containerid);
            favorites.setParameters("containerid", userMeObject.containerid);
        }
        favorites.getRequest();
    }

    function _removeFromFavorites(weiboId) {
        wbFunc.addNotification(qsTr("Removing from favorites"))
        if (tokenProvider.useHackLogin)
            favoritesDestroy.appendPostDataParameters("id", weiboId);
        else
            favoritesDestroy.setParameters("id", weiboId);
        favoritesDestroy.postRequest();
    }
    WrapperFavoritesList {
        id: favorites
        onRequestAbort: {
            console.log("== favorites onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== favorites onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== favorites onRequestSuccess ["+replyData+"]")

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
    /*FavoritesDestroy*/WrapperFavoritesDestroy {
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
                    wbFunc.toUserPage(userId);
                }
                onLabelLinkClicked: {
                    Qt.openUrlExternally(link);
                }
                onLabelImageClicked: {
                    wbFunc.toGalleryPage(modelImages, index);
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
