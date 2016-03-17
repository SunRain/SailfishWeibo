import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL
import "../WeiboFunctions.js" as WBLoader
import "../js/Utility.js" as Utility

import "../components"

import harbour.sailfish_sinaweibo.sunrain 1.0

Page {
    id: weiboPage

    property var userWeiboJSONContent
    property var weiboHackLoginSuffix: undefined
    
    property int _footInfoBarIndex: 0
    property int _commentsPageNum:1
    property int _repostPageNum: 1
    property bool _gettingInfo: false
    property string _weiboId: ""
    property var _hackLoginStatusShowObject: undefined

    function _getInfo(id) {
        weiboPage._gettingInfo = true;
        _weiboId = String(id);
        modelInfo.clear();
        if (_footInfoBarIndex == 0) {
            statusesRepostTimeline.setParameters("id", " "+id+" ");
            statusesRepostTimeline.setParameters("page", _repostPageNum);
            statusesRepostTimeline.setParameters("count", 20)  //单页返回的记录条数，默认为50。
            statusesRepostTimeline.getRequest();
        }
        
        if (_footInfoBarIndex == 1) {
            commentsShow.setParameters("id", " "+id+" ");
            commentsShow.setParameters("page", _commentsPageNum);
            commentsShow.setParameters("count", 20)  //单页返回的记录条数，默认为50。
            commentsShow.getRequest();
        }

    }
    function _addMore() {
        weiboPage._gettingInfo = true;
        var method
        if (_footInfoBarIndex == 0) {
            _repostPageNum++;
            statusesRepostTimeline.setParameters("id", " "+_weiboId+" ");
            statusesRepostTimeline.setParameters("page", _repostPageNum);
            statusesRepostTimeline.setParameters("count", 20)  //单页返回的记录条数，默认为50。
            statusesRepostTimeline.getRequest();
        }
        
        if (_footInfoBarIndex == 1) {
            _commentsPageNum++;
            commentsShow.setParameters("id", " "+_weiboId+" ");
            commentsShow.setParameters("page", _commentsPageNum);
            if (!tokenProvider.useHackLogin)
                commentsShow.setParameters("count", 20)  //单页返回的记录条数，默认为50。
            commentsShow.getRequest();
        }

    }
    
    WrapperCommentsShow {
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
            if (commentListView.model == undefined)
                commentListView.model = modelInfo;
        }
    }

    WrapperStatusesRepostTimeline{
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
            if (commentListView.model == undefined)
                commentListView.model = modelInfo;
        }
    }
    ListModel {
        id: modelInfo
    }
    onStatusChanged: {
//        console.log("====== weiboPage status " + status)
        if (weiboPage.status == PageStatus.Active) {
            if (weiboPage.weiboHackLoginSuffix) {
                if (!_hackLoginStatusShowObject) {
                    WBLoader.create("../requests/RQHackStatusesShow.qml", weiboPage, function(object, component, incubator) {
                        weiboPage._hackLoginStatusShowObject = object;
                        if (weiboPage._hackLoginStatusShowObject) {
                            weiboPage._hackLoginStatusShowObject.requestResult.connect(function(ret, replyData) {
                                console.log("=== RQHackStatusesShow connect ===");
                                if (ret == BaseRequest.RET_SUCCESS) {
                                    console.log("== RQHackStatusesShow onRequestSuccess")
                                    userWeiboJSONContent = undefined;
                                    userWeiboJSONContent = Utility.parserHackStatusesShow(JSON.parse(replyData));
                                } else {
                                    wbFunc.addNotification(qsTr("Request for addNotification error!!"));
                                }
                            });
                            weiboPage._hackLoginStatusShowObject.resetUrlPath(weiboPage.weiboHackLoginSuffix);
                            weiboPage._hackLoginStatusShowObject.getRequest();
                        }
                    });
                }
            }
        }
    }

    SilicaFlickable {
        id: main
        anchors {
            top: parent.top
            bottom: toolBar.top
        }
        width: parent.width
        contentHeight: column.height
        clip: true

        Column {
            id:column
            width: parent.width
            spacing: Theme.paddingMedium
            PageHeader {
                id:pageHeader
                title: qsTr("Sailfish Weibo")
            }
            WeiboCard {
                id:weiboCard
                width: parent.width - Theme.paddingMedium * 2
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingMedium
                }
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
                onRepostButtonClicked: {
//                    _footInfoBarIndex = 0;
//                    _getInfo(userWeiboJSONContent.id);
                }
                onCommentButtonClicked: {
//                    _footInfoBarIndex = 1;
//                    _getInfo(userWeiboJSONContent.id);
                }
                onLikeButtonClicked: {
//                        footInfoBarIndex = 2;
                }

                ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Repost")
                        onClicked: {
                            wbFunc.toSendPage("repost", {"id": userWeiboJSONContent.id},
                                       (userWeiboJSONContent.retweeted_status == undefined || userWeiboJSONContent.retweeted_status == "") == true ?
                                           "" :
                                           "//@"+userWeiboJSONContent.user.name +": " + userWeiboJSONContent.text ,
                                           true)
                        }
                    }
                    MenuItem {
                        text: qsTr("Comment")
                        onClicked: {
                            wbFunc.toSendPage("comment", {"id": userWeiboJSONContent.id}, "", true)
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

    BottomPopupToolBar {
        id: toolBar
        anchors {
            bottom: parent.bottom
            left: parent.left
        }
        popupContent: Item {
            anchors.fill: parent
            SilicaListView {
                id: commentListView
                anchors.fill: parent
                clip: true
                spacing: Theme.paddingSmall
                delegate: delegateComment
                footer: FooterLoadMore {
                    visible: modelInfo.count != 0
                    onClicked: {
                        _addMore();
                    }
                }
                VerticalScrollDecorator {}
            }
            BusyIndicator {
                id: busyIndicator
                size: BusyIndicatorSize.Medium
                anchors.centerIn: parent
                running: weiboPage._gettingInfo
            }
        }
        onPopupReady: {
            console.log("==== toolBar onPopupReady ")
            _getInfo(userWeiboJSONContent.id);
        }
        toolBarContent: Item {
            id: tools
            width: parent.width - Theme.paddingLarge*2//parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.itemSizeMedium
            property int index: 0
            Image {
                id: background
                anchors.fill: parent
                source: "image://theme/graphic-header"
            }
            Rectangle {
                id: indicator
                anchors.top: tools.top
                height: Theme.paddingSmall
                color: Theme.highlightColor
                width: tools.width/2
                x: tools.width * tools.index /2
                Behavior on x {
                    NumberAnimation {duration: 200}
                }
            }
            Row {
                anchors.centerIn: parent
                BackgroundItem {
                    id: repostLabel
                    width: tools.width/2
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Repost")
                        color: repostLabel.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: {
                        tools.index = 0;
                        _footInfoBarIndex = 0;
                        if (toolBar.popuped)
                            _getInfo(userWeiboJSONContent.id);
                    }
                }
                BackgroundItem {
                    id: commentLabel
                    width: tools.width/2
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Comment")
                        color: commentLabel.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: {
                        tools.index = 1;
                        _footInfoBarIndex = 1;
                        if (toolBar.popuped)
                            _getInfo(userWeiboJSONContent.id);
                    }
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
                width: parent.width - Theme.paddingMedium *2
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: Theme.paddingMedium
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
                    weiboTime:  DateUtils.formatRelativeTime(DateUtils.parseDate(appUtility.dateParse(model.created_at)))
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
                    text: wbParser.parseWeiboContent(model.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                }
            }
            
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Reply")
                        onClicked: {
                            var commentInfo = { "id": userWeiboJSONContent.id, "cid": model.id}
                            if (tokenProvider.useHackLogin) {
                                var placeHold = qsTr("Reply to")+":@"+model.user.screen_name+" ";
                                console.log("===== reply to "+placeHold)
                                wbFunc.toSendPage("reply", commentInfo, placeHold)
                            } else {
                                wbFunc.toSendPage("reply", commentInfo)
                            }
                        }
                    }
                }
            }
        }
    }
}
