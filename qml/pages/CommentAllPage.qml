import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
//import "../js/Settings.js" as Settings
import "../js/getURL.js" as GetURL
import "../components"

import harbour.sailfish_sinaweibo.sunrain 1.0

WBPage {
    id: commentAllPage

    property var uid
    property string userName: ""
    property int _pageNum: 1

    property var _commentInfo
    property var _weiboTmp

    function refresh() {
        modelComment.clear()

        _pageNum = 1
        _commentAll(_pageNum)
    }

    function _addMore() {
        _pageNum++
        _commentAll(_pageNum)
    }

    /*CommentsTimeline*/WrapperCommentsTimeline {
        id: commentsTimeline
        onRequestAbort: {
            console.log("== commentsTimeline onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== commentsTimeline onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            //            console.log("== commentsTimeline onRequestSuccess ")//["+replyData+"]")
            var result = JSON.parse(replyData);
            for (var i=0; i<result.comments.length; ++i) {
                modelComment.append(result.comments[i])
            }
            if (commentListView.model == undefined)
                commentListView.model = modelComment;
            wbFunc.stopBusyIndicator();
        }
    }

    //////////////////////////////////////////////////////////////////         get all comment
    function _commentAll(page) {
        wbFunc.showBusyIndicator();
        commentsTimeline.setParameters("page", _pageNum);
        commentsTimeline.getRequest();
    }

    ListModel { id: modelComment }

    SilicaListView {
        id: commentListView
        anchors.fill: parent
        spacing: Theme.paddingLarge
        delegate: delegateComment

        cacheBuffer: 9999
        header:PageHeader {
            id:pageHeader
            title: qsTr("All comments")
        }
        footer: FooterLoadMore {
            visible: modelComment.count != 0
            onClicked: {_addMore()}
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    commentAllPage.refresh();
                }
            }
        }
    }

    Component {
        id: delegateComment

        Column {
            width: parent.width
            spacing: Theme.paddingSmall

            WeiboCard {
                id: weiboCard
                width: parent.width - Theme.paddingMedium * 2
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingMedium
                }
                weiboJSONContent: modelComment.get(index)
                optionMenu: options
                onRepostedWeiboClicked: {
                }
                onUsWeiboClicked: {
                }
                onAvatarHeaderClicked: {
                }
                onLabelLinkClicked: {
                }
                onLabelImageClicked: {
                }
                ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Reply comment")
                        onClicked: {
                            /////////// Ugly code
                            commentAllPage._commentInfo = { "id": model.status.id, "cid": model.id}
                            commentAllPage._weiboTmp = model.status
                            //toSendPage("reply", commentAllPage.commentInfo)
                            pageStack.push(Qt.resolvedUrl("SendPage.qml"),
                                           {"mode":"reply",
                                               "userInfo":commentAllPage._commentInfo})
                        }
                    }
                    MenuItem {
                        text: qsTr("View weibo")
                        onClicked: {
                            /////////// Ugly code
                            pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                           {"userWeiboJSONContent":model.status})
                        }
                    }
                }
            }
            Separator {
                width: parent.width
                color: Theme.highlightColor
            }
        }
    }// component

    ListModel {
        id: modelWeiboTemp
    }

}
