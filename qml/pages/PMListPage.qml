import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

WBPage {
    id: pmListPage


    property bool _showUnfollow: false
    property int _index: 1
    property int _pageNum: 1

    function refresh() {
        if (_showUnfollow)
            _refreshNoteList();
        else
            _refreshPMList();
    }

    function _refreshPMList() {
        _showUnfollow = false;
        _pageNum = 1;
        listModel.clear();
        pmList.setParameters("page", _pageNum);
        pmList.getRequest();
    }
    function _refreshNoteList() {
        _showUnfollow = true;
        _pageNum = 1;
        listModel.clear();
        pmNoteList.setParameters("page", _pageNum);
        pmNoteList.getRequest();
    }
    function _addMore() {
        _pageNum++;
        if (_showUnfollow) {
            pmNoteList.setParameters("page", _pageNum);
            pmNoteList.getRequest();
        } else {
            pmList.setParameters("page", _pageNum);
            pmList.getRequest();
        }
    }

    HackPrivateMessageList {
        id: pmList
        onRequestResult: { //ret, replyData
            if (ret != BaseRequest.RET_SUCCESS) {
                console.log("== HackPrivateMessageList ret "+ret+" replydata " + replyData)
            } else {
                var jsonObj = JSON.parse(replyData);
                for (var i=0; i<jsonObj.length; ++i) {
                    var topObj = jsonObj[i].card_group;
                    if (topObj == undefined)
                        continue;
                    for (var j=0; j<topObj.length; ++j) {
                        var sndObj = topObj[j];
                        if (sndObj.user == undefined)
                            continue;
                        listModel.append(sndObj);
                    }
                }
            }
        }
    }
    HackPrivateMessageNoteList {
        id: pmNoteList
        onRequestResult: {
            if (ret != BaseRequest.RET_SUCCESS) {
                console.log("== HackPrivateMessageNoteList ret "+ret+" replydata " + replyData)
            } else {
                var data = wbParser.parseHackPrivateMessageNoteList(replyData);
                var obj = JSON.parse(data);
                for (var i=0; i<obj.length; ++i) {
                    listModel.append(obj[i]);
                }
            }
        }
    }


    SilicaListView {
        id: listView
        width: parent.width
        anchors {
            top: parent.top
            bottom: toolBar.top
        }
        header: PageHeader{
            title: _showUnfollow ? qsTr("Unfollowed PM") : qsTr("followed PM")
        }
        ScrollDecorator{}
        model: ListModel {
            id: listModel
        }
        footer: FooterLoadMore {
            visible: listModel.count > 0
            onClicked: {
                _addMore();
            }
        }
        delegate: pmListComponent
    }

    Rectangle {
        id: toolBar
        width: parent.width
        height: Theme.itemSizeMedium
        anchors.bottom: parent.bottom
        color: Theme.highlightDimmerColor
        property int index: _showUnfollow ? 1 : 0
        Rectangle {
            id: indicator
            anchors.top: toolBar.top
            height: Theme.paddingSmall
            color: Theme.highlightColor
            width: toolBar.width/2
            x: toolBar.width * toolBar.index/2
            Behavior on x {
                NumberAnimation {duration: 200}
            }
        }
        Row {
            anchors.centerIn: parent
            BackgroundItem {
                width: toolBar.width/2
                Label {
                    anchors.centerIn: parent
                    text: qsTr("followed message")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    if (_showUnfollow) {
                        _showUnfollow = false;
                        refresh();
                    }
                }
            }
            BackgroundItem {
                width: toolBar.width/2
                Label {
                    anchors.centerIn: parent
                    text: qsTr("unfollowed message")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    if (!_showUnfollow) {
                        _showUnfollow = true;
                        refresh();
                    }
                }
            }
        }
    }

    Component {
        id: pmListComponent
        Column {
            id: pmListColumn
            width: parent.width
            spacing: Theme.paddingSmall
            BackgroundItem {
                width: parent.width
                height: Math.max(avatar.height, column.height)
                onClicked: {
                    wbFunc.toPMChatPage(model.user.id, model.user.screen_name)
                }

                MouseArea {
                    id: avatar
                    height: Theme.itemSizeMedium
                    width: height
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                    }
                    Image {
                        anchors.fill: parent
                        source: _showUnfollow
                        //silly typo, sina used a wrong word, should be avatar lol
                                ? listModel.get(index).data.sender.avanta
                                : model.user.avatar_large
                        fillMode: Image.PreserveAspectFit
                    }
                    onClicked: {
                        if (_showUnfollow) {
                            wbFunc.toUserPage(listModel.get(index).data.sender.uid)
                        } else {
                            wbFunc.toUserPage(model.user.id)
                        }
                    }
                }
                Column {
                    id: column
                    anchors {
                        top: parent.top
                        left: avatar.right
                        leftMargin: Theme.paddingMedium
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }
                    Row {
                        spacing: Theme.paddingMedium
                        Rectangle {
                            width: model.unread > 0 ? Theme.fontSizeTiny /2 : 0
                            height: Theme.fontSizeTiny /2
                            anchors.top: parent.top
                            radius: 90
                            color: Theme.highlightColor
                            opacity: model.unread > 0
                        }
                        Label {
                            anchors.bottom: parent.bottom
                            text: _showUnfollow
                                  ? listModel.get(index).data.sender.name
                                  : model.user.screen_name
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.highlightColor
                        }
                        Label {
                            anchors.bottom: parent.bottom
                            text: _showUnfollow
                                  ? listModel.get(index).data.time
                                  : model.created_at
                            font.pixelSize: Theme.fontSizeTiny
                            color: Theme.secondaryHighlightColor
                        }
                    }
                    Label {
                        width: parent.width
                        text: _showUnfollow
                              ? wbParser.parseWeiboContent(listModel.get(index).data.text,
                                                           Theme.primaryColor,
                                                           Theme.highlightColor,
                                                           Theme.secondaryHighlightColor)
                              : model.text
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.primaryColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.StyledText
                        onLinkActivated: { //link
                            console.log("=== click "+link)
                            var data = link.split("||");
                            if (data[0] == "LinkTopic")
                                Qt.openUrlExternally(data[1]);
                            else if (data[0] == "LinkUnknow")
                                Qt.openUrlExternally(data[1]);
                            else if (data[0] == "LinkWebOrVideo")
                                Qt.openUrlExternally(data[1]);
                            else if (data[0] == "LinkAt")
                                wbFunc.toUserPage("", data[1].replace(/\//, ""))
                            else
                                Qt.openUrlExternally(link);
                        }
                    }
                }
            }
            Separator {
                width: parent.width
                color: Theme.secondaryHighlightColor
            }
            Item {
                width: parent.width
                height: pmListColumn.spacing
            }
        }
    } //pmListComponent
}

