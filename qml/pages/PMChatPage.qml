import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

Page {
    id: pmChatPage

    property var uid: undefined
    property var chatPerson: undefined
    property int _pageNum: 1
    property string _token: ""

    Component.onCompleted: {
        token.setParameters("uid", uid);
        token.getRequest();
    }

    onStatusChanged: {
        if (pmChatPage.status == PageStatus.Active) {
            refresh();
        }
    }

    function refresh() {
        listModel.clear();
        _pageNum = 1;
        chatRequest.setParameters("page", _pageNum);
        chatRequest.setParameters("uid", uid);
        chatRequest.getRequest();
    }

    function _addMore() {
        _pageNum++;
        chatRequest.setParameters("page", _pageNum);
        chatRequest.setParameters("uid", uid);
        chatRequest.getRequest();
    }

    function _sendMsg(content) {
        chatSend.setParameters("uid", uid);
        chatSend.setParameters("content", content);
        chatSend.setParameters("st", _token);
        chatSend.postRequest();
    }

    HackPrivateMessageToken {
        id: token
        onRequestResult: { //ret, replyData
            if (ret != BaseRequest.RET_SUCCESS) {
                console.log("== HackPrivateMessageToken ret "+ret+" replydata " + replyData);
                wbFunc.addNotification(qsTr("Oops, get message token error, can't send pm!!!"));
            } else {
//               console.log("== HackPrivateMessageToken RET_SUCCESS replydata " + replyData)
                _token = wbParser.parseHackPrivateMessageToken(replyData);
                console.log("== HackPrivateMessageToken token "+_token)
            }
        }
    }

    HackPrivateMessageChatList {
        id: chatRequest
        onRequestResult: { //ret, replyData
            if (ret != BaseRequest.RET_SUCCESS) {
                console.log("== HackPrivateMessageChatList ret "+ret+" replydata " + replyData)
            } else {
                var jsonObj = JSON.parse(replyData);
                var topObj = jsonObj.data;
                for (var i=0; i<topObj.length; ++i) {
                    listModel.append(topObj[i])
                }
            }
        }
    }
    HackPrivateMessageSend {
        id: chatSend
        onRequestResult: { //ret, replyData
            if (ret != BaseRequest.RET_SUCCESS) {
                console.log("== HackPrivateMessageChatList ret "+ret+" replydata " + replyData)
                wbFunc.addNotification(replyData);
            } else {
                var jsonObj = JSON.parse(replyData);
                if (jsonObj.ok == "1") {
                    refresh();
                    wbFunc.addNotification(jsonObj.msg);
                } else {
                    wbFunc.addNotification(replyData);
                }
            }
        }
    }

    SilicaFlickable {
        id: mainView
        anchors.fill: parent
        contentHeight: parent.height
        PullDownMenu {
            MenuItem {
                text: qsTr("Send")
                onClicked: {
                }
            }
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Send")
                onClicked: {
                }
            }
        }
        SilicaListView {
            id: chatListView
            width: parent.width - Theme.horizontalPageMargin*2
            x: Theme.horizontalPageMargin
            clip: true
            anchors {
                top: parent.top
                bottom: inputArea.top
                bottomMargin: Theme.paddingMedium
            }
            header: PageHeader{
                title: chatPerson == undefined ? qsTr("Unknow person") : chatPerson
            }
            ScrollDecorator{}
            model: ListModel {
                id: listModel
            }
            footer: FooterLoadMore {
                visible: listModel.count > 0
                onClicked: {
                }
            }
            delegate: chatViewComponent
        }
        Item {
            id: inputArea
            width: parent.width - Theme.horizontalPageMargin*2
            x: Theme.horizontalPageMargin
            height: Math.max(input.height, sendBtn.height)
            anchors.bottom: parent.bottom
            TextArea {
                id: input
                anchors {
                    left: parent.left
                    right: sendBtn.left
                    bottom: parent.bottom
                }
                horizontalAlignment: TextInput.AlignLeft
            }
            BackgroundItem {
                id: sendBtn
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                width: label.width
                height: label.height + Theme.paddingLarge *2
                onClicked: {
                    if (input.text == undefined || input.text == "") {
                        wbFunc.addNotification(qsTr("Can't send empty msg"));
                    } else {
                        _sendMsg(encodeURIComponent(input.text))
                    }
                }
                Label {
                    id: label
                    text: qsTr("Send")
                    font.pixelSize: Theme.fontSizeMedium
                    color: parent.highlighted ? Theme.highlightColor: Theme.primaryColor
                }
            }
        }
    }

    Component {
        id: chatViewComponent
        Item {
            id: mainDelegate
            width: parent.width
            height: Math.max(lavatar.height, lArrow.height, content.height) + Theme.paddingLarge
            property bool isSenderMe: model.sender.id != pmChatPage.uid
            Image {
                id: lavatar
                width: Theme.iconSizeMedium
                height: width
                anchors {
                    left: parent.left
                    top: parent.top
                }
                visible: !isSenderMe
                source: model.sender.profile_image_url
            }
            Image {
                id: lArrow
                source: appUtility.pathTo("qml/graphics/char_info_l.png")
                anchors {
                    left: lavatar.right
                    leftMargin: Theme.paddingSmall
                    verticalCenter: lavatar.verticalCenter
                }
                opacity: 0.1
                visible: !isSenderMe
            }
            Rectangle {
                id: content
                anchors {
                    top: parent.top
                    left: lArrow.right
                    right: rArrow.left
                }
                height: contentLabel.height > lavatar.height
                        ? contentLabel.height
                        : lavatar.height
                radius: 5;
                color: "#1affffff"
                Label {
                    id: contentLabel
                    width: parent.width - Theme.paddingMedium *2
                    x: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    textFormat: Text.StyledText
                    horizontalAlignment: isSenderMe ? Text.AlignRight : Text.AlignLeft
                    text: model.text
                    onLinkActivated: {
                        Qt.openUrlExternally(link)
                    }
                }
            }
            Image {
                id: rArrow
                source: appUtility.pathTo("qml/graphics/char_info_r.png")
                anchors {
                    right: ravatar.left
                    rightMargin: Theme.paddingSmall
                    verticalCenter: ravatar.verticalCenter
                }
                opacity: 0.1
                visible: isSenderMe
            }
            Image {
                id: ravatar
                width: Theme.iconSizeMedium
                height: width
                anchors {
                    right: parent.right
                    top: parent.top
                }
                visible: isSenderMe
                source: model.sender.profile_image_url
            }
        }
    } //Component
}

