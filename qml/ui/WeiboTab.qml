import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"
//import "../js/Settings.js" as Settings

/*************************************************
  微博程序的首页以及微博条目展示列表
*************************************************/

SilicaListView {
    id: weiboTab
    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height
    property int _allWeiboPageNum: 1
    property int _groupWeiboPageNum: 1
    property string _groupIdstr: ""

    property bool _isGroupType: false

    signal fetchPending
    signal fetchFinished

    StatusesFriendsTimeline {
        id: statusesFriendsTimeline
        onRequestAbort: {
            console.log("== statusesFriendsTimeline onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== statusesFriendsTimeline onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            var jsonObj = JSON.parse(replyData);
            for (var i=0; i<jsonObj.statuses.length; i++) {
                modelWeibo.append(jsonObj.statuses[i])
            }
            if (weiboTab.model == undefined) {
                weiboTab.model = modelWeibo;
            }
            fetchFinished();
        }
    }

    /*FriendshipsGroupsTimeline*/WrapperFriendshipsGroupsTimeline {
        id: friendshipsGroupsTimeline
        onRequestAbort: {
            console.log("== friendshipsGroupsTimeline onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== friendshipsGroupsTimeline onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== friendshipsGroupsTimeline onRequestSuccess ["+replyData+"]")
            var jsonObj = JSON.parse(replyData);
            for (var i=0; i<jsonObj.statuses.length; i++) {
                modelWeibo.append(jsonObj.statuses[i])
            }
            if (weiboTab.model == undefined) {
                weiboTab.model = modelWeibo;
            }
            fetchFinished();
        }
    }

    FavoritesCreate {
        id: favoritesCreate
        onRequestAbort: {
            console.log("== favoritesCreate onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== favoritesCreate onRequestFailure ["+replyData+"]")
            addNotification(qsTr("Fail to add to favorites"));
        }
        onRequestSuccess: { //replyData
            addNotification(qsTr("Succeed to add to favorites"));
        }
    }

    function refresh() {
        //showBusyIndicator();
        fetchPending();
        modelWeibo.clear();
        _allWeiboPageNum = 1;
        _isGroupType = false;
//        var method = WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;
//        api.setWeiboAction(method, {
//                               'page':_allWeiboPageNum,
//                               'access_token':settings.accessToken//Settings.getAccess_token()
//                           });
        statusesFriendsTimeline.setParameters("page", " "+_allWeiboPageNum);
        statusesFriendsTimeline.getRequest();
    }
    
    function addMore() {
        fetchPending();
        if(_isGroupType) {
            _groupWeiboPageNum++;
//            var method = WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE;
//            api.setWeiboAction(method, {
//                                   "page":_groupWeiboPageNum,
//                                   "access_token":settings.accessToken, //Settings.getAccess_token(),
//                                   "list_id":_groupIdstr});
            friendshipsGroupsTimeline.setParameters("page", " "+_groupWeiboPageNum);
            friendshipsGroupsTimeline.setParameters("list_id", _groupIdstr);
            friendshipsGroupsTimeline.getRequest();
        } else {
            _allWeiboPageNum++;
//            var method = WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE;
//            api.setWeiboAction(method, {
//                                   'page':_allWeiboPageNum,
//                                   'access_token':settings.accessToken//Settings.getAccess_token()
//                               });
            statusesFriendsTimeline.setParameters("page", _allWeiboPageNum);
            statusesFriendsTimeline.getRequest();
        }
    }

    function showAllWeibo() {
        refresh();
    }

    function addToFavorites(weiboId) {
        addNotification(qsTr("Start adding to favorites"));
//        var method = WeiboMethod.WBOPT_POST_FAVORITES_CREATE; //添加收藏
//        api.setWeiboAction(method, {
//                               "id":" "+weiboId+" ", //FIXME: How can I avoid to change string ==> int when using QVariant ?
//                               "access_token":settings.accessToken//Settings.getAccess_token()
//                           });
        favoritesCreate.setParameters("id", " "+weiboId);
        favoritesCreate.postRequest();
    }

    function showGroupWeibo(groupIdstr) {
        //        WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE, //获取某一好友分组的微博列表
        //showBusyIndicator();
        fetchPending();
        modelWeibo.clear();
        _groupWeiboPageNum = 1;
        _groupIdstr = groupIdstr;
        _isGroupType = true;
//        var method = WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE;
//        api.setWeiboAction(method, {
//                               "page":_groupWeiboPageNum,
//                               "access_token":settings.accessToken,//Settings.getAccess_token(),
//                               "list_id":_groupIdstr});
        friendshipsGroupsTimeline.setParameters("page", " "+_groupWeiboPageNum);
        friendshipsGroupsTimeline.setParameters("list_id", _groupIdstr);
        friendshipsGroupsTimeline.getRequest();
    }

    ListModel {
        id: modelWeibo
    }
    
//    Connections {
//        target: api
//        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
//        //weiboPutFail(mWeiboMethod.getWeiboAction(parseRequestedWeiboPutUrl(requestedUrl)), error);
//        onWeiboPutSucceed: {
//            if (action == WeiboMethod.WBOPT_GET_STATUSES_FRIENDS_TIMELINE
//                    || action == WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE) {
//                var jsonObj = JSON.parse(replyData);
//                for (var i=0; i<jsonObj.statuses.length; i++) {
//                    modelWeibo.append(jsonObj.statuses[i])
//                }
//                if (weiboTab.model == undefined) {
//                    weiboTab.model = modelWeibo;
//                }
//                fetchFinished();
//            }
//            if (action == WeiboMethod.WBOPT_POST_FAVORITES_CREATE) {
//                addNotification(qsTr("Succeed to add to favorites"));
//            }
//        }
//        onWeiboPutFail: {
//            if (action == WeiboMethod.WBOPT_POST_FAVORITES_CREATE) {
//                addNotification(qsTr("Fail to add to favorites"));
//            }
//        }
//        onTokenExpired: {}
//    }

    cacheBuffer: 999999
    // model: modelWeibo
    footer: modelWeibo.count == 0 ? null : footerComponent
    delegate: delegateWeibo
    spacing: Theme.paddingSmall
    clip: true
    
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
            width: parent.width
            spacing: Theme.paddingMedium
            WeiboCard {
                id:weiboCard
                width: parent.width - Theme.paddingMedium * 2
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingMedium
                }
                weiboJSONContent: modelWeibo.get(index)
                optionMenu: options
                onRepostedWeiboClicked: {
                    toWeiboPage(modelWeibo.get(index).retweeted_status);
                }
                onUsWeiboClicked: {
                    toWeiboPage(modelWeibo.get(index));
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
                            toSendPage("repost",
                                       {"id": model.id},
                                       (model.retweeted_status == undefined || model.retweeted_status == "") == true
                                       ? ""
                                       : "//@"+model.user.name +": " + model.text ,
                                         true);
                        }
                    }
                    MenuItem {
                        text: qsTr("Comment")
                        onClicked: {
                            toSendPage("comment", {"id": model.id}, "", true);
                        }
                    }
                    MenuItem {
                        text: qsTr("Add to favorites")
                        onClicked: {
                            addToFavorites(model.id);
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
