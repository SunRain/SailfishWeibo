import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
//import "../js/Settings.js" as Settings
import "../js/getURL.js" as GetURL
import "../components"

import harbour.sailfish_sinaweibo.sunrain 1.0

WBPage{
    id: commentMentionedPage
    //title: qsTr("Comments mentioned me")

    property var uid
    property string userName: ""
    property int _pageNum: 1

    property var _commentInfo
    property var _weiboTmp

//    property alias contentItem: commentMentionedListView

    function refresh() {
        modelComment.clear()

        _pageNum = 1
//        isRefresh = true
        _commentMentioned(_pageNum)
    }

    function _addMore() {
        _pageNum++
        _commentMentioned(_pageNum)
    }

    //////////////////////////////////////////////////////////////////         get all comment mentioned me
    function _commentMentioned(page) {
        showBusyIndicator();
        commentsMentions.setParameters("page", _pageNum);
        commentsMentions.getRequest();
    }
    
    CommentsMentions {
        id: commentsMentions
        onRequestAbort: {}
        onRequestFailure: { //replyData
        }
        onRequestSuccess: { //replyData
            var result = JSON.parse(replyData);
            for (var i=0; i<result.comments.length; i++) {
                modelComment.append( result.comments[i] )
            }
            stopBusyIndicator();
        }
    }

    SilicaListView {
        id: commentMentionedListView
        anchors.fill: parent
        model: ListModel { id: modelComment }
        delegate: delegateComment
        cacheBuffer: 9999
        header:PageHeader {
            id:pageHeader
            title: qsTr("Comments mentioned me")
        }
        footer: FooterLoadMore {
            visible: modelComment.count != 0
            onClicked: {_addMore()}
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    commentMentionedPage.refresh();
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
                        text:  qsTr("Reply")
                        onClicked: {
                            /////////// Ugly code
                            commentMentionedPage._commentInfo = { "id": model.status.id, "cid": model.id}
                            commentMentionedPage._weiboTmp = model.status
                            //toSendPage("reply", commentMentionedPage.commentInfo)
                            pageStack.push(Qt.resolvedUrl("SendPage.qml"),
                                           {"mode":"reply",
                                               "userInfo":commentMentionedPage._commentInfo})
                        }
                    }
                    MenuItem {
                        text: qsTr("View weibo")
                        onClicked: {
                            /////////// Ugly code
                            //                            commentMentionedPage.commentInfo = { "id": model.status.id, "cid": model.id}
                            //                            commentMentionedPage.weiboTmp = model.status

                            //                            modelWeiboTemp.clear()
                            //                            modelWeiboTemp.append(weiboTmp)
                            //                            //toWeiboPage(modelWeiboTemp, 0)
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
