import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

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

    WrapperCommentsTimeline {
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
                    }
                }
                onUsWeiboClicked: {
                    if (!tokenProvider.useHackLogin) {
                        wbFunc.toWeiboPage(modelWeibo.get(index).status);
                    }
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
                onContentVideoImgClicked: {
                    Qt.openUrlExternally(link)
                }
                ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Reply comment")
                        onClicked: {
                            /////////// Ugly code
                            if (tokenProvider.useHackLogin) {
                                commentAllPage._commentInfo = {"id": model.card.page_id,
                                                               "cid": model.id,
                                                               "replyToUser": model.user.screen_name}
                            } else {
                                commentAllPage._commentInfo = { "id": model.status.id, "cid": model.id}
                            }
                            commentAllPage._weiboTmp = model.status
                            if (tokenProvider.useHackLogin) {
                                var placeHold = qsTr("Reply to")+":"+model.user.screen_name+" ";
                                wbFunc.toSendPage("reply", commentAllPage._commentInfo, placeHold)
                            } else {
                                wbFunc.toSendPage("reply", commentAllPage._commentInfo)
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
