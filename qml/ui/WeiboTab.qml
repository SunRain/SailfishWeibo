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

    WrapperStatusesFriendsTimeline {
        id: statusesFriendsTimeline
        onRequestAbort: {
            console.log("== statusesFriendsTimeline onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== statusesFriendsTimeline onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            var jsonObj = JSON.parse(replyData);

            console.log("== statusesFriendsTimeline onRequestSuccess ["+replyData+"]")

            for (var i=0; i<jsonObj.statuses.length; i++) {
                modelWeibo.append(jsonObj.statuses[i])
            }
            if (weiboTab.model == undefined) {
                weiboTab.model = modelWeibo;
            }
            fetchFinished();
        }
    }

    WrapperFriendshipsGroupsTimeline {
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

    WrapperFavoritesCreate {
        id: favoritesCreate
        onRequestAbort: {
            console.log("== favoritesCreate onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== favoritesCreate onRequestFailure ["+replyData+"]")
            wbFunc.addNotification(qsTr("Fail to add to favorites"));
        }
        onRequestSuccess: { //replyData
            console.log("== favoritesCreate onRequestSuccess ["+replyData+"]")
            wbFunc.addNotification(qsTr("Succeed to add to favorites"));
        }
    }

    function refresh() {
        if (_isGroupType) {
            showGroupWeibo(_groupIdstr);
        } else {
            showAllWeibo();
        }
    }
    
    function addMore() {
        fetchPending();
        if(_isGroupType) {
            _groupWeiboPageNum++;
            friendshipsGroupsTimeline.setParameters("page", " "+_groupWeiboPageNum);
            friendshipsGroupsTimeline.setParameters("list_id", _groupIdstr);
            friendshipsGroupsTimeline.getRequest();
        } else {
            _allWeiboPageNum++;
            statusesFriendsTimeline.setParameters("page", _allWeiboPageNum);
            statusesFriendsTimeline.getRequest();
        }
    }

    function showAllWeibo() {
        fetchPending();
        modelWeibo.clear();

        _isGroupType = false;
        _allWeiboPageNum = 1;

        statusesFriendsTimeline.setParameters("page", " "+_allWeiboPageNum);
        statusesFriendsTimeline.getRequest();
    }

    function addToFavorites(weiboId) {
        wbFunc.addNotification(qsTr("Start adding to favorites"));
        if (tokenProvider.useHackLogin)
            favoritesCreate.appendPostDataParameters("id", " "+weiboId);
        else
            favoritesCreate.setParameters("id", " "+weiboId);
        favoritesCreate.postRequest();
    }

    function showGroupWeibo(groupIdstr) {
        //        WBOPT_GET_FRIENDSHIPS_GROUPS_TIMELINE, //获取某一好友分组的微博列表
        fetchPending();
        modelWeibo.clear();
        _groupWeiboPageNum = 1;
        _groupIdstr = groupIdstr;
        _isGroupType = true;
        friendshipsGroupsTimeline.setParameters("page", " "+_groupWeiboPageNum);
        friendshipsGroupsTimeline.setParameters("list_id", _groupIdstr);
        friendshipsGroupsTimeline.getRequest();
    }

    ListModel {
        id: modelWeibo
    }
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
                    wbFunc.toWeiboPage(modelWeibo.get(index).retweeted_status);
                }
                onUsWeiboClicked: {
                    wbFunc.toWeiboPage(modelWeibo.get(index));
                }
                onAvatarHeaderClicked: {
                    wbFunc.toUserPage(userId);
                }
                onLabelLinkClicked: {
                }
                onLinkAtClicked: {
                    wbFunc.toUserPage("", link.replace(/\//, ""))
                }
                onLinkTopicClicked: {
                    console.log("==== onLinkTopicClicked "+ link)
                    Qt.openUrlExternally(link);
                }
                onLinkUnknowClicked: {
                    Qt.openUrlExternally(link);
                }
                onLinkWebOrVideoClicked: {
                    console.log("==== onLinkWebOrVideoClicked "+ link)
                    Qt.openUrlExternally(link);
                }
                onLabelImageClicked: {
                    wbFunc.toGalleryPage(modelImages, index);
                }
                onContentVideoImgClicked: {
                    Qt.openUrlExternally(link)
                }
                ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Repost")
                        onClicked: {
                            var info;
                            if (tokenProvider.useHackLogin) {
                                info = {"id": model.id, "rtid": model.user.id}
                            } else {
                                info = {"id": model.id};
                            }
                            wbFunc.toSendPage("repost", info,
                                       (model.retweeted_status == undefined || model.retweeted_status == "")
                                       ? ""
                                       : "//@"+model.user.name +": " + model.text);
                        }
                    }
                    MenuItem {
                        text: qsTr("Comment")
                        onClicked: {
                            wbFunc.toSendPage("comment", {"id": model.id});
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
