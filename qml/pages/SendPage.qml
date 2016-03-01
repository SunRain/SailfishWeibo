import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

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
        id:atUserSheet
        AtUserComponent {
            id:atUserComponent
            anchors.fill: parent           
            onUserClicked: {
                console.log("SendPage === We love " + userName);
//                drawer.open = !drawer.open;
                if (toolBar.popuped)
                    toolBar.hidePopup();
                parent.focus = true;
                content.text += " @" + userName + " "
            }
            onCloseIconClicked: {
                if (toolBar.popuped)
                    toolBar.hidePopup();
                parent.focus = true;
            }
            onFetchPending: {
                pullDownMenu.busy = true;
                pushUpMenu.busy = true;
            }
            onFetchFinish: {
                pullDownMenu.busy = false;
                pushUpMenu.busy = false;
            }
        }
    }

    Component {
        id:commentOption
        ComboBox {
            id: commentOptionComboBox
            width: parent.width
            label: qsTr("comment option")
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
    }

    Component {
        id: repostOption
        ComboBox {
            id: repostTypeComboBox
            width: parent.parent
            label: qsTr("repost option")
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
    
    /////////////////////////////// 主页面
    SilicaFlickable {
        id: mainView
        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width
        clip: true
        SilicaFlickable {
            anchors {
                top: parent.top
                bottom: toolBar.top
            }
            width: parent.width
            clip: true
            contentHeight: column.height
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
                MenuItem {
                    text: qsTr("Send")
                    onClicked: {
                        console.log("SendPage == SendIcon click, we send [" + content.text +"]  for mode "
                                    + sendPage.mode + " with option " + optionIndex);
                        wbSender.sendWeibo();
                    }
                }
            }
            VerticalScrollDecorator {}
            Column {
                id: column
                spacing: Theme.paddingLarge
                width: parent.width
//                enabled: !drawer.opened
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
                    columns: 4
//                    columns: 1
                    spacing: Theme.paddingSmall
                    width: parent.width
                    height: childrenRect.height
                    Repeater {
                        model: wbSender.imageModel//ListModel { id: modelImages }
                        delegate: /*Component {*/
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
                                    console.log("==== imageModel " +wbSender.imageModel.get(index))
                                    console.log("==== imageModel path " +wbSender.imageModel.get(index).path)
                                    console.log("==== imageModel path string "
                                                +JSON.stringify(wbSender.imageModel.get(index)));
                                    console.log("==== imageModel path json "
                                                +JSON.parse(JSON.stringify(wbSender.imageModel.get(index))).path);
                                    appUtility.pathPrefix(wbSender.imageModel.get(index).path)
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("SendPage === inserted image clicked" + index);
//                                        modelImages.remove(index);
                                        wbSender.imageModel.remove(index, 1)
//                                        wbSender.setImgPath("");
                                    }
                                    onDoubleClicked: {
                                        console.log("SendPage === inserted image onDoubleClicked")
                                    }
                                }
                            }
//                        }
                    }
                }
                Loader {
                    id: optionLoader
                    width: parent.width
                }
            }

            //添加输入框下部选型列表
            Component.onCompleted: {
                optionLoader.sourceComponent = optionLoader.Null;
                switch (mode) {
                case "repost" :
                    sendTitle = qsTr("Repost")
                    //selectorType.values = repostType
                    optionLoader.sourceComponent = repostOption;
                    break;
                case "comment" :
                    sendTitle = qsTr("Comment")
                    //selectorType.values = commentType
                    optionLoader.sourceComponent = commentOption;
                    break;
                case "reply" :
                    sendTitle = qsTr("Reply")
                    // selectorType.values = commentType
                    optionLoader.sourceComponent = commentOption;
                    break;
                default:
                    //sendPage.mode = ""
                    sendTitle = qsTr("Send Weibo")
                    // selectorType.values = [""]
                    break
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
                PageHeader {
                    id: popHeader
                    title: qsTr("Close")
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            toolBar.loaderType = -1
                            popLoader.sourceComponent = popLoader.Null;
                            toolBar.hidePopup();
                        }
                    }
                    extraContent.data: [
                        BusyIndicator {
                            size: BusyIndicatorSize.Small
                            anchors.centerIn: parent
//                            running: groupItem.showBusyIndicator
//                            opacity: running ? 1 : 0
                        }
                    ]
                }
                Loader {
                    id: popLoader
                    width: parent.width
                    anchors {
                        top: popHeader.bottom
                        bottom: parent.bottom
                    }
                    sourceComponent: {
                        if (toolBar.loaderType == 1)
                            return atUserSheet;
                        return popLoader.Null
                    }
                    onStatusChanged: {
                        if (popLoader.status == Loader.Ready) {
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
//                                    modelImages.clear();
                                    wbSender.imageModel.clear();
                                }
//                                modelImages.append(
//                                            {"path":tmp}
//                                            );
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
                            source: appUtility.pathTo("qml/graphics/btn_insert_at_1.png")
                        }
                        onClicked: {
                            toolBar.loaderType = 1;
                        }
                    }
//                    BackgroundItem {
//                        width: parent.width/3
//                        height: tools.height * 0.8
//                        Image {
//                            anchors.centerIn: parent
//                            height: parent.height
//                            width: height
//                            fillMode: Image.PreserveAspectFit
//                            source: appUtility.pathTo("qml/graphics/btn_insert_pics_1.png")
//                        }
//                        onClicked: {
//                            toolBar.loaderType = 2;
//                        }
//                    }
                }
            }
        }

    }



//    Drawer {
//        id: drawer
//        anchors.fill: parent
//        dock: Dock.Bottom
        
//        background: Loader {
//            id:drawerBackgroundLoader
//            anchors.fill: parent
//            //sourceComponent: atUserSheet
//        }
        
//        SilicaFlickable {
//            anchors {
//                fill: parent
//                //leftMargin: page.isPortrait ? 0 : controlPanel.visibleSize
//                //topMargin: page.isPortrait ? controlPanel.visibleSize : 0
//                //rightMargin: page.isPortrait ? 0 : progressPanel.visibleSize
//                //bottomMargin: page.isPortrait ? progressPanel.visibleSize : 0
//            }
            
////            //打开Draw的时候点击任意界面关闭
//            MouseArea {
//                enabled: drawer.open
//                anchors.fill: column
//                onClicked: drawer.open = false
//            }
            
//            PullDownMenu {
//                id: pullDownMenu
//                MenuItem {
//                    text: qsTr("Send")
//                    onClicked: {
//                        console.log("SendPage == SendIcon click, we send [" + content.text +"]  for mode "
//                                    + sendPage.mode + " with option " + optionIndex);
//                        wbSender.sendWeibo();
//                    }
//                }
//            }

//            PushUpMenu {
//                id: pushUpMenu
//                MenuItem {
//                    text: qsTr("@SomeOne")
//                    onClicked: {
//                        drawerBackgroundLoader.sourceComponent = drawerBackgroundLoader.Null
//                        drawerBackgroundLoader.sourceComponent = atUserSheet;
//                        if (!drawer.opened) {
//                            drawer.open = true;
//                        }
//                    }
//                }
//                MenuItem {
//                    text: qsTr("Add Image")
//                    onClicked: {
//                        var imagePicker = pageStack.push("Sailfish.Pickers.ImagePickerPage");
//                        imagePicker.selectedContentChanged.connect(function() {
//                            var imagePath = imagePicker.selectedContent;
//                            var tmp = imagePath.toString().replace("file://", "");
//                            modelImages.clear();
//                            modelImages.append(
//                                        {"path":tmp}
//                                        );
//                            wbSender.setImgPath(imagePath);
//                        });
//                    }
//                }
//            }

//            contentHeight: column.height + Theme.paddingLarge
            
//            VerticalScrollDecorator {}
            
//            Column {
//                id: column
//                spacing: Theme.paddingLarge
//                width: parent.width
//                enabled: !drawer.opened

//                PageHeader { title: sendTitle }
                
//                ////////////////////////////////////////文字输入框
                
//                TextArea {
//                    id:content
//                    width: parent.width
//                    height: Math.max(parent.width/2, implicitHeight)
//                    focus: true
//                    horizontalAlignment: TextInput.AlignLeft
//                    //placeholderText: qsTr("Input Weibo content here");
//                    text: placeHoldText
//                    label: "Expanding text area"
//                }
                
//                Label {
//                    visible: modelImages.count > 0
//                    width: parent.width
//                    color: Theme.secondaryColor
//                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                    font.pixelSize: Theme.fontSizeExtraSmall
//                    text: qsTr("Click the inserted image to remove from the uploading queue")
//                }

//                Grid {
//                    id: gridWeiboPics
//                    //columns: 4
//                    columns: 1
//                    spacing: Theme.paddingSmall
//                    width: parent.width
//                    height: childrenRect.height
                    
//                    Repeater {
//                        model: ListModel { id: modelImages }
//                        delegate: Component {
//                            Image {
//                                id:image
//                                fillMode: Image.PreserveAspectFit
//                                width: modelImages.count == 1 ? implicitWidth : column.width / 4 - Theme.paddingSmall
//                                height: modelImages.count == 1 ? implicitHeight : width
//                                source: appUtility.pathPrefix(model.path)
//                                MouseArea {
//                                    anchors.fill: parent
//                                    onClicked: {
//                                        console.log("SendPage === inserted image clicked" + index);
//                                        modelImages.remove(index);
//                                        wbSender.setImgPath("");
//                                    }
//                                    onDoubleClicked: {
//                                        console.log("SendPage === inserted image onDoubleClicked")
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }

//                Loader {
//                    id: optionLoader
//                    width: parent.width
//                }
//            }

//            //添加输入框下部选型列表
//            Component.onCompleted: {
//                optionLoader.sourceComponent = optionLoader.Null;
//                switch (mode) {
//                case "repost" :
//                    sendTitle = qsTr("Repost")
//                    //selectorType.values = repostType
//                    optionLoader.sourceComponent = repostOption;
//                    break;
//                case "comment" :
//                    sendTitle = qsTr("Comment")
//                    //selectorType.values = commentType
//                    optionLoader.sourceComponent = commentOption;
//                    break;
//                case "reply" :
//                    sendTitle = qsTr("Reply")
//                    // selectorType.values = commentType
//                    optionLoader.sourceComponent = commentOption;
//                    break;
//                default:
//                    //sendPage.mode = ""
//                    sendTitle = qsTr("Send Weibo")
//                    // selectorType.values = [""]
//                    break
//                }
//            }
//        }
//    }
}
    
