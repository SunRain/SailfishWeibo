import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

WBPage{
    id: commentMentionedPage

    property var uid
    property string userName: ""
    property int _pageNum: 1

    property var _commentInfo
    property var _weiboTmp
    function refresh() {
        modelComment.clear()
        _pageNum = 1
        _commentMentioned(_pageNum)
    }

    function _addMore() {
        _pageNum++
        _commentMentioned(_pageNum)
    }

    //////////////////////////////////////////////////////////////////         get all comment mentioned me
    function _commentMentioned(page) {
        wbFunc.showBusyIndicator();
        commentsMentions.setParameters("page", _pageNum);
        commentsMentions.getRequest();
    }
    
    WrapperCommentsMentions {
        id: commentsMentions
        onRequestAbort: {}
        onRequestFailure: { //replyData
        }
        onRequestSuccess: { //replyData
            var result = JSON.parse(replyData);
            for (var i=0; i<result.comments.length; i++) {
                modelComment.append( result.comments[i] )
            }
            wbFunc.stopBusyIndicator();
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
            spacing: Theme.paddingMedium
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
                    if (tokenProvider.useHackLogin) {
                        var suffix = modelComment.get(index).card.page_url;
                        console.log("===== onRepostedWeiboClicked  suffix "+suffix);
                        wbFunc.toWeiboPage(modelComment.get(index).card, suffix);
                    } else {
                        wbFunc.toWeiboPage(modelComment.get(index).retweeted_status);
                    }
                }
                onUsWeiboClicked: {
                    if (!tokenProvider.useHackLogin) {
                        wbFunc.toWeiboPage(modelWeibo.get(index));
                    }
                }
                onAvatarHeaderClicked: {
                    wbFunc.toUserPage(userId);
                }
                onLabelLinkClicked: {}
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
                        text:  qsTr("Reply")
                        onClicked: {
                            /////////// Ugly code
                            if (tokenProvider.useHackLogin) {
                                commentMentionedPage._commentInfo = {"id": model.card.page_id,
                                                                    "cid": model.id,
                                                                    "replyToUser": model.user.screen_name}
                            } else {
                                commentMentionedPage._commentInfo = { "id": model.status.id, "cid": model.id}
                            }
                            commentMentionedPage._weiboTmp = model.status
                            if (tokenProvider.useHackLogin) {
                                var placeHold = qsTr("Reply to")+":"+model.card.page_title+" ";
                                wbFunc.toSendPage("reply", commentMentionedPage._commentInfo, placeHold)
                            } else {
                                wbFunc.toSendPage("reply", commentMentionedPage._commentInfo)
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
    }// component
}
