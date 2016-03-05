import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

WBPage {
    id: weiboMentionedPage

    property var uid
    property string userName: ""
    property int _pageNum: 1

    function refresh() {
        modelWeibo.clear()

        _pageNum = 1
        _weiboMentioned(_pageNum)
    }

    function _addMore() {
        _pageNum++
        _weiboMentioned(_pageNum)
    }

    //////////////////////////////////////////////////////////////////         user status mentioned me
    function _weiboMentioned(page) {
        wbFunc.showBusyIndicator();
        statusesMentions.setParameters("page", _pageNum);
        statusesMentions.getRequest();
    }

    WrapperStatusesMentions {
        id: statusesMentions
        onRequestAbort: {
            console.log("== statusesMentions onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== statusesMentions onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== statusesMentions onRequestSuccess ["+replyData+"]")

            var jsonObj = JSON.parse(replyData);
            for (var i=0; i<jsonObj.statuses.length; i++) {
                modelWeibo.append( jsonObj.statuses[i] )
            }
            if (lvUserWeibo.model == undefined) {
                lvUserWeibo.model = modelWeibo;
            }
            wbFunc.stopBusyIndicator();
        }
    }

    SilicaListView{
        id: lvUserWeibo
        anchors.fill: parent
        cacheBuffer: 999999
        footer: FooterLoadMore {
            visible: modelWeibo.count != 0
            onClicked: { weiboMentionedPage._addMore();}
        }
        delegate: delegateWeibo
        header:PageHeader {
            id:pageHeader
            title: qsTr("Weibo mentioned me")
        }
        ScrollDecorator{flickable: lvUserWeibo}
        pullDownMenu: PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    weiboMentionedPage.refresh();
                }
            }
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
                    if (tokenProvider.useHackLogin) {
                        var suffix = modelWeibo.get(index).card.page_url;
                        console.log("===== onRepostedWeiboClicked  suffix "+suffix);
                        wbFunc.toWeiboPage(modelWeibo.get(index).card, suffix);
                    } else {
                        wbFunc.toWeiboPage(modelWeibo.get(index).retweeted_status);
                    }
                }
                onUsWeiboClicked: {
                    if (tokenProvider.useHackLogin) {
                        var suffix = modelWeibo.get(index).user.id +"/"+modelWeibo.get(index).bid
                        console.log("===== onUsWeiboClicked  suffix "+suffix);
                        wbFunc.toWeiboPage(modelWeibo.get(index), suffix);
                    } else {
                        wbFunc.toWeiboPage(modelWeibo.get(index));
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
                ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Repost")
                        onClicked: {
                            wbFunc.toSendPage("repost", {"id": model.id},
                                       (model.retweeted_status == undefined || model.retweeted_status == "") == true ?
                                           "" :
                                           "//@"+model.user.name +": " + model.text ,
                                           false)
                        }
                    }
                    MenuItem {
                        text: qsTr("Comment")
                        onClicked: {
                            wbFunc.toSendPage("comment", {"id": model.id}, "", false)
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
    }

    ListModel {
        id: modelWeibo
    }
}
