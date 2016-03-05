import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"
import "../ui"

Page {
    id: sendPage
    property string mode: ""
    onModeChanged: {
        wbSender.mode = mode;
    }

//    property var repostType: [qsTr("No comments"), qsTr("Comment current Weibo"), qsTr("Comment original Weibo"), qsTr("Both")]
//    property var commentType: [qsTr("Do not comment original Weibo"), qsTr("Also comment original Weibo")]
    
    property string sendTitle
    property var userInfo         // include id, cid, etc..
    onUserInfoChanged: {
        wbSender.userInfo = userInfo;
    }

    property string placeHoldText:""
    property var optionIndex: undefined
    onOptionIndexChanged: {
        console.log("====== sendPage onOptionIndexChanged "+optionIndex);
        if (optionIndex == undefined)
            var a = 0
        else
            a = optionIndex
        wbSender.optionIndex = a;
    }

    property alias contentText: content.text
    onContentTextChanged: {
        wbSender.contentText = contentText;
    }
    Component.onCompleted: {
        wbSender.imageModel.clear();
    }

    Component {
        id: atUserSheet
        Item {
            anchors.fill: parent
            AtUserComponent {
                id: atUserComponent
                anchors {
                    top: parent.top
                    bottom: searchArea.top
                }
                onUserClicked: {
                    console.log("SendPage === We love " + userName);
//                    if (toolBar.popuped) {
//                        toolBar.loaderType = -1;
//                        toolBar.hidePopup();
//                    }
                    sendPage.focus = true;
                    content.text += " @" + userName + " "
                }
                onFetchPending: {
//                    pullDownMenu.busy = true;
//                    pushUpMenu.busy = true;
                }
                onFetchFinish: {
//                    pullDownMenu.busy = false;
//                    pushUpMenu.busy = false;
                    parent.focus = true;
                }
            }
            Row {
                id: searchArea
                spacing: Theme.paddingSmall
                width: parent.width
                height: Math.max(searchInput.height, searchIcon.height + Theme.paddingSmall)
                anchors.bottom: parent.bottom
                TextField {
                    id: searchInput
                    width: parent.width - searchIcon.width - searchArea.spacing
                    label: qsTr("search") + " " +searchInput.text
                    placeholderText: "Type here"
                    focus: true
                    horizontalAlignment: TextInput.AlignLeft
                    EnterKey.iconSource: searchInput.text.length > 0 && searchInput.text != placeHoldText
                                         ? "image://theme/icon-m-search" : ""
                    EnterKey.onClicked: {
                        if (searchInput.text.length > 0 && searchInput.text != placeHoldText)
                            atUserComponent.searchAtUser(searchInput.text);
                        else
                            parent.focus = true;
                    }
                }
                IconButton {
                    id:searchIcon
                    icon.source: "image://theme/icon-m-search"
                    highlighted: down || searchInput._editor.activeFocus
                    enabled: searchInput.enabled
                    onClicked: {
                        atUserComponent.searchAtUser(searchInput.text);
                    }
                }
            }
        }
    }
    function showAtUserSheet() {
        console.log("=== showAtUserSheet")
        toolBar.loaderType = 1;
        popLoader.sourceComponent = atUserSheet;
    }

    function resetLoader() {
        console.log("=== resetLoader")
        toolBar.loaderType = -1;
        popLoader.sourceComponent = popLoader.Null;
        if (toolBar.popuped)
            toolBar.hidePopup();
    }

    /////////////////////////////// 主页面
    SilicaFlickable {
        id: mainView
        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width
        clip: true
        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                text: qsTr("Send")
                onClicked: {
                    console.log("SendPage == SendIcon click, we send [" + content.text +"]  for mode "
                                + sendPage.mode + " with option " + optionIndex);
                    wbSender.sendWeibo();
                }
            }
        }
        PushUpMenu {
            id: pushUpMenu
            MenuItem {
                text: qsTr("Send")
                onClicked: {
                    console.log("SendPage == SendIcon click, we send [" + content.text +"]  for mode "
                                + sendPage.mode + " with option " + optionIndex);
                    wbSender.sendWeibo();
                }
            }
        }
        SilicaFlickable {
            anchors {
                top: parent.top
                bottom: toolBar.top
            }
            width: parent.width
            clip: true
            contentHeight: column.height
            VerticalScrollDecorator {}
            Column {
                id: column
                spacing: Theme.paddingLarge
                width: parent.width
                PageHeader { title: sendTitle }
                ////////////////////////////////////////文字输入框
                TextArea {
                    id: content
                    width: parent.width
                    height: Math.max(parent.width/2, implicitHeight)
                    focus: true
                    horizontalAlignment: TextInput.AlignLeft
                    //placeholderText: qsTr("Input Weibo content here");
                    text: placeHoldText
                    label: "Weibo content"
                }
                Label {
                    visible: wbSender.imageModel.count > 0//modelImages.count > 0
                    width: parent.width
                    color: Theme.secondaryColor
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Click the inserted image to remove from the uploading queue")
                }

                Grid {
                    id: gridWeiboPics
                    columns: tokenProvider.useHackLogin ? 4 : 1
                    spacing: Theme.paddingSmall
                    width: parent.width
                    height: childrenRect.height
                    function removeItem(index) {
                        imageRepeater.model = undefined;
                        wbSender.imageModel.remove(index, 1);
                        imageRepeater.model = wbSender.imageModel;
                    }

                    Repeater {
                        id: imageRepeater
                        model: wbSender.imageModel
                        delegate:
                            Image {
                            id:image
                            fillMode: Image.PreserveAspectFit
                            width: tokenProvider.useHackLogin
                                   ? column.width / 4
                                   : /*modelImages.count*/wbSender.imageModel.count == 1 ? implicitWidth : column.width / 4 - Theme.paddingSmall
                            height: tokenProvider.useHackLogin
                                    ? width *2
                                    : /*modelImages.count*/wbSender.imageModel.count == 1 ? implicitHeight : width
                            source: {
                                console.log("==== imageModel path string "
                                            +JSON.stringify(wbSender.imageModel.get(index)));
                                appUtility.pathPrefix(wbSender.imageModel.get(index).path)
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    gridWeiboPics.removeItem(index);
                                }
                                onDoubleClicked: {
                                    console.log("SendPage === inserted image onDoubleClicked")
                                }
                            }
                        }
                    }
                }
                TextSwitch {
                    id: hackReplyTypeCheck
                    width: parent.width
                    visible: mode == "reply" && tokenProvider.useHackLogin
                    enabled: mode == "reply" && tokenProvider.useHackLogin
                    text: qsTr("Also repost to my weibo")
                    checked: optionIndex == 1
                    onCheckedChanged: {
                        if (checked)
                            optionIndex = 1;
                        else
                            optionIndex = 0
                    }
                }
                ComboBox {
                    id: commentOptionComboBox
                    width: parent.width
                    label: qsTr("comment option")
                    visible: (mode == "comment" || mode == "reply") && !tokenProvider.useHackLogin
                    enabled: (mode == "comment" || mode == "reply") && !tokenProvider.useHackLogin
                    currentIndex: 0
                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("Do not comment original Weibo")
                            onClicked: { optionIndex = 0; }
                        }
                        MenuItem {
                            text: qsTr("Also comment original Weibo")
                            onClicked: { optionIndex = 1;}
                        }
                    }
                }
                ComboBox {
                    id: repostTypeComboBox
                    width: parent.width
                    label: qsTr("repost option")
                    visible: mode == "repost" ? true : false
                    enabled: mode == "repost" ? true : false
                    currentIndex: 0
                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("No comments")
                            onClicked: { optionIndex = 0; }
                        }
                        MenuItem {
                            text: qsTr("Comment current Weibo")
                            onClicked: { optionIndex = 1; }
                        }
                        MenuItem {
                            text: qsTr("Comment original Weibo")
                            onClicked:  { optionIndex = 2; }
                        }
                        MenuItem {
                            text: qsTr("Both")
                            onClicked:  { optionIndex = 3; }
                        }
                    }
                }
            }
        }
        BottomPopupToolBar {
            id: toolBar
            anchors {
                bottom: parent.bottom
                left: parent.left
            }
            enableToolbarMenu: false
            property int loaderType: -1
            onPopupReady: {}
            popupContent: Item {
                anchors.fill: parent
                Loader {
                    id: popLoader
                    anchors.fill: parent
                    onStatusChanged: {
                        if (popLoader.status == Loader.Ready) {
                            console.log("===== Loader status Ready ")
                            if (!toolBar.popuped)
                                toolBar.showPopup();
                        }
                    }
                }
            }
            toolBarContent: Item {
                id: tools
                width: parent.width - Theme.paddingLarge*2
                anchors.horizontalCenter: parent.horizontalCenter
                height: Theme.itemSizeSmall
                Row {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    BackgroundItem {
                        width: parent.width/2
                        height: tools.height * 0.8
                        Image {
                            anchors.centerIn: parent
                            height: parent.height
                            width: height
                            fillMode: Image.PreserveAspectFit
                            source: appUtility.pathTo("qml/graphics/btn_insert_pics_1.png")
                        }
                        onClicked: {
                            var imagePicker = pageStack.push("Sailfish.Pickers.ImagePickerPage");
                            imagePicker.selectedContentChanged.connect(function() {
                                var imagePath = imagePicker.selectedContent;
                                var tmp = imagePath.toString().replace("file://", "");
                                if (!tokenProvider.useHackLogin) {
                                    wbSender.imageModel.clear();
                                }
                                wbSender.setImgPath(imagePath);
                            });
                        }
                    }
                    BackgroundItem {
                        width: parent.width/2
                        height: tools.height * 0.8
                        Image {
                            anchors.centerIn: parent
                            height: parent.height
                            width: height
                            fillMode: Image.PreserveAspectFit
                            source: toolBar.popuped
                                    ? "image://theme/icon-m-clear"
                                    : appUtility.pathTo("qml/graphics/btn_insert_at_1.png")
                        }
                        onClicked: {
                            if (toolBar.loaderType != -1) {
                                resetLoader();
                            } else {
                                showAtUserSheet();
                            }
                        }
                    }
                }
            }
        }
    }
}
    
