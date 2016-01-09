import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
//import "../js/Settings.js" as Settings
import "../js/getURL.js" as GetURL

import "../components"

import harbour.sailfish_sinaweibo.sunrain 1.0

Page {
    id: weiboPage

    property var userWeiboJSONContent
    
    property int _footInfoBarIndex: 0
    property int _commentsPageNum:1
    property int _repostPageNum: 1
    property bool _gettingInfo: false
    property string _weiboId

    function _getInfo(id) {
        weiboPage._gettingInfo = true;
        _weiboId = String(id);
        modelInfo.clear();
        var method;
        if (_footInfoBarIndex == 0) {
//            method = WeiboMethod.WBOPT_GET_STATUSES_REPOST_TIMELINE;
//            api.setWeiboAction(method, {'id':" "+id+" ", 'page':_repostPageNum});
            statusesRepostTimeline.setParameters("id", " "+id+" ");
            statusesRepostTimeline.setParameters("page", _repostPageNum);
            statusesRepostTimeline.getRequest();
        }
        
        if (_footInfoBarIndex == 1) {
//            method = WeiboMethod.WBOPT_GET_COMMENTS_SHOW;
//            api.setWeiboAction(method, {'id':" "+id+" ", 'page':_commentsPageNum});
            commentsShow.setParameters("id", " "+id+" ");
            commentsShow.setParameters("page", _commentsPageNum);
            commentsShow.getRequest();
        }

    }
    function _addMore() {
        weiboPage._gettingInfo = true;
        var method
        if (_footInfoBarIndex == 0) {
            _repostPageNum++;
//            method = WeiboMethod.WBOPT_GET_STATUSES_REPOST_TIMELINE;
//            api.setWeiboAction(method, {'id':" "+_weiboId+" ", 'page':_repostPageNum});
            statusesRepostTimeline.setParameters("id", " "+_weiboId+" ");
            statusesRepostTimeline.setParameters("page", _repostPageNum);
            statusesRepostTimeline.getRequest();
        }
        
        if (_footInfoBarIndex == 1) {
            _commentsPageNum++;
//            method = WeiboMethod.WBOPT_GET_COMMENTS_SHOW;
//            api.setWeiboAction(method, {'id':" "+_weiboId+" ", 'page':_commentsPageNum});
            commentsShow.setParameters("id", " "+_weiboId+" ");
            commentsShow.setParameters("page", _commentsPageNum);
            commentsShow.getRequest();
        }

    }
    onStatusChanged: {
        if (weiboPage.status == PageStatus.Active) {
            _getInfo(userWeiboJSONContent.id);
        }
    }
    
    CommentsShow {
        id: commentsShow
        onRequestAbort: {
            weiboPage._gettingInfo = false
            console.log("== commentsShow onRequestAbort");
        }
        onRequestFailure: { //replyData
            weiboPage._gettingInfo = false
            console.log("== commentsShow onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            weiboPage._gettingInfo = false
            var json = JSON.parse(replyData);
            for (var i=0; i<json.comments.length; i++) {
                modelInfo.append(json.comments[i])
            }
        }
    }

    StatusesRepostTimeline {
        id: statusesRepostTimeline
        onRequestAbort: {
            weiboPage._gettingInfo = false
            console.log("== statusesRepostTimeline onRequestAbort");
        }
        onRequestFailure: { //replyData
            weiboPage._gettingInfo = false
            console.log("== statusesRepostTimeline onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            weiboPage._gettingInfo = false
            var json = JSON.parse(replyData);
            for (var i=0; i<json.reposts.length; ++i) {
                modelInfo.append(json.reposts[i])
            }
        }
    }

//    Connections {
//        target: api
//        onWeiboPutSucceed: {
//            weiboPage._gettingInfo = false
//            if (action == WeiboMethod.WBOPT_GET_COMMENTS_SHOW) {
//                var json = JSON.parse(replyData);
//                for (var i=0; i<json.comments.length; i++) {
//                    modelInfo.append(json.comments[i])
//                }
//            }
//            if (action == WeiboMethod.WBOPT_GET_STATUSES_REPOST_TIMELINE) {
//                json = JSON.parse(replyData);
//                for (i=0; i<json.reposts.length; i++) {
//                    modelInfo.append(json.reposts[i])
//                }
//            }
//        }
//    }
    
    SilicaFlickable {
        id: main
        anchors.fill: parent

        boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        contentHeight: column.height

        Column {
            id:column
            
            anchors{left:parent.left; right:parent.right }
            spacing: Theme.paddingMedium
            
            PageHeader {
                id:pageHeader
                title: qsTr("Sailfish Weibo")
            }
                
            WeiboCard {
                id:weiboCard
                parent: column
                weiboJSONContent: userWeiboJSONContent
                optionMenu: options
                repostButtonColor: _footInfoBarIndex == 0 ? Theme.secondaryHighlightColor : undefined
                commentButtonColor: _footInfoBarIndex == 1 ? Theme.secondaryHighlightColor : undefined
                likeButtonColor: _footInfoBarIndex == 2 ? Theme.secondaryHighlightColor : undefined

                onRepostedWeiboClicked: {
                    pageStack.replace(Qt.resolvedUrl("WeiboPage.qml"),
                                      {"userWeiboJSONContent":userWeiboJSONContent.retweeted_status})
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
                onRepostButtonClicked: {
                    _footInfoBarIndex = 0;
                    _getInfo(userWeiboJSONContent.id);
                }
                onCommentButtonClicked: {
                    _footInfoBarIndex = 1;
                    _getInfo(userWeiboJSONContent.id);
                }
                onLikeButtonClicked: {
                    //                        footInfoBarIndex = 2;
                }

                ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Repost")
                        onClicked: {
                            toSendPage("repost", {"id": userWeiboJSONContent.id},
                                       (userWeiboJSONContent.retweeted_status == undefined || userWeiboJSONContent.retweeted_status == "") == true ?
                                           "" :
                                           "//@"+userWeiboJSONContent.user.name +": " + userWeiboJSONContent.text ,
                                           true)
                        }
                    }
                    MenuItem {
                        text: qsTr("Comment")
                        onClicked: {
                            toSendPage("comment", {"id": userWeiboJSONContent.id}, "", true)
                        }
                    }
                }
            }
            
            Separator {
                width: parent.width
                color: Theme.highlightColor
            }            
            //////////////微博下面评论/转发的内容（listView展示）
            Item {
                id: commentItem
                width: parent.width
                height: childrenRect.height
                BusyIndicator {
                    id: commentLoading
                    anchors.centerIn: parent
                    parent: commentItem
                    size: BusyIndicatorSize.Medium
                    opacity: commentLoading.running ? 1 : 0
                    running: weiboPage._gettingInfo ? (modelInfo.count == 0 ? true : false) : false
                }
                SilicaListView {
                    id:commentListView
                    width: parent.width
                    height: modelInfo.count ==0 ? 0 : contentItem.childrenRect.height
                    opacity: modelInfo.count ==0 ? 0 : 1
                    header: PageHeader {
                        title: _footInfoBarIndex == 0
                               ? qsTr("Repost")
                               : _footInfoBarIndex == 1
                               ? qsTr("Comment")
                               : qsTr("Repost") //fallback
                    }

                    interactive: false
                    clip: true
                    spacing:Theme.paddingSmall
                    model: ListModel {
                        id: modelInfo
                    }
                    delegate: delegateComment
                    footer: FooterLoadMore {
                        visible: modelInfo.count != 0
                        onClicked: {
                            _addMore();
                        }
                    }
                    VerticalScrollDecorator { /*flickable: commentListView*/ }
                    Behavior on opacity { FadeAnimation{} }
                }
            }
        }
    }
    
    Component {
        id: delegateComment

        OptionItem {
            width: parent.width
            contentHeight: columnWContent.height
            menu: contextMenu
            Column {
                id: columnWContent
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingSmall
                    rightMargin: Theme.paddingSmall
                }
                spacing: Theme.paddingMedium
                
                ////////用户头像/姓名/评论发送时间
                UserAvatarHeader {
                    id:commnetAvaterHeader
                    width: parent.width
                    height:Theme.itemSizeExtraSmall
                    
                    userName: model.user.screen_name
                    userNameFontSize: Theme.fontSizeTiny
                    userAvatar: model.user.profile_image_url
                    weiboTime:  DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(model.created_at)))
                                + qsTr(" From ") + GetURL.linkToStr(model.source)
                    onUserAvatarClicked: {
                        toUserPage(model.user.id)
                    }
                }
                
                /////////评论/转发内容
                Label {
                    id: labelWeibo
                    width: parent.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    //color: Theme.primaryColor
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: util.parseWeiboContent(model.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                }
            }
            
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Reply")
                        onClicked: {
                            var commentInfo = { "id": userWeiboJSONContent.id, "cid": model.id}
                            pageStack.push(Qt.resolvedUrl("SendPage.qml"),
                                           {"mode":"reply",
                                               "userInfo":commentInfo})
                        }
                    }
                }
            }
        }
    
    }
}
