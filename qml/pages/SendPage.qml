import QtQuick 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.Popups 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
import "../js/weiboapi.js" as WB
//import "../js/Settings.js" as Settings
import Sailfish.Silica 1.0

//import QtDocGallery 5.0
//import org.nemomobile.thumbnailer 1.0

import "../components"
import harbour.sailfish_sinaweibo.sunrain 1.0

Page {
    id: sendPage
    property string mode: ""
    onModeChanged: {
        wbSend.mode = mode;
    }

//    property var repostType: [qsTr("No comments"), qsTr("Comment current Weibo"), qsTr("Comment original Weibo"), qsTr("Both")]
//    property var commentType: [qsTr("Do not comment original Weibo"), qsTr("Also comment original Weibo")]
    
    property string sendTitle
    property var userInfo         // include id, cid, etc..
    onUserInfoChanged: {
        wbSend.userInfo = userInfo;
    }

    property string placeHoldText:""
    property string imgPath: ""
    property int optionIndex: 0

    property alias contentText: content.text
    onContentTextChanged: {
        wbSend.contentText = contentText;
    }

    Component {
        id:atUserSheet
        AtUserComponent {
            id:atUserComponent
            anchors.fill: parent           
            onUserClicked: {
                console.log("SendPage === We love " + userName);
                drawer.open = !drawer.open;
                parent.focus = true;
                
                content.text += " @" + userName + " "
            }
            onCloseIconClicked: {
                drawer.hide();
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
    Drawer {
        id: drawer
        anchors.fill: parent
        dock: Dock.Bottom
        
        background: Loader {
            id:drawerBackgroundLoader
            anchors.fill: parent
            //sourceComponent: atUserSheet
        }
        
        SilicaFlickable {
            anchors {
                fill: parent
                //leftMargin: page.isPortrait ? 0 : controlPanel.visibleSize
                //topMargin: page.isPortrait ? controlPanel.visibleSize : 0
                //rightMargin: page.isPortrait ? 0 : progressPanel.visibleSize
                //bottomMargin: page.isPortrait ? progressPanel.visibleSize : 0
            }
            
//            //打开Draw的时候点击任意界面关闭
            MouseArea {
                enabled: drawer.open
                anchors.fill: column
                onClicked: drawer.open = false
            }
            
            PullDownMenu {
                id: pullDownMenu
                MenuItem {
                    text: qsTr("Send")
                    onClicked: {
                        console.log("SendPage == SendIcon click, we send [" + content.text +"]  for mode " 
                                    + sendPage.mode + " with option " + optionIndex);
                        wbSend.sendWeibo();
                    }
                }
            }

            PushUpMenu {
                id: pushUpMenu
                MenuItem {
                    text: qsTr("@SomeOne")
                    onClicked: {
                        drawerBackgroundLoader.sourceComponent = drawerBackgroundLoader.Null
                        drawerBackgroundLoader.sourceComponent = atUserSheet;
                        if (!drawer.opened) {
                            drawer.open = true;
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Add Image")
                    onClicked: {
//                        drawerBackgroundLoader.sourceComponent = drawerBackgroundLoader.Null
//                        drawerBackgroundLoader.sourceComponent = insertImageSheet;
//                        if (!drawer.opened) {
//                            drawer.open = true;
//                        }
                        var imagePicker = pageStack.push("Sailfish.Pickers.ImagePickerPage");
                        imagePicker.selectedContentChanged.connect(function() {
                            var imagePath = imagePicker.selectedContent;
                            var tmp = imagePath.toString().replace("file://", "");
                            modelImages.clear();
                            modelImages.append(
                                        {"path":tmp}
                                        );
                            wbSend.setImgPath(imagePath);
                        });
                    }
                }
            }

            contentHeight: column.height + Theme.paddingLarge
            
            VerticalScrollDecorator {}
            
            Column {
                id: column
                spacing: Theme.paddingLarge
                width: parent.width
                enabled: !drawer.opened

                PageHeader { title: sendTitle }
                
                ////////////////////////////////////////文字输入框
                
                TextArea {
                    id:content
                    width: parent.width
                    height: Math.max(parent.width/2, implicitHeight)
                    focus: true
                    horizontalAlignment: TextInput.AlignLeft
                    //placeholderText: qsTr("Input Weibo content here");
                    text: placeHoldText
                    label: "Expanding text area"                   
                }
                
                Label {
                    visible: modelImages.count > 0
                    width: parent.width
                    color: Theme.secondaryColor
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Click the inserted image to remove from the uploading queue")
                }

                Grid {
                    id: gridWeiboPics
                    //columns: 4
                    columns: 1
                    spacing: Theme.paddingSmall
                    width: parent.width
                    height: childrenRect.height
                    
                    Repeater {
                        model: ListModel { id: modelImages }
                        delegate: Component {
                            Image {
                                id:image
                                fillMode: Image.PreserveAspectFit
                                width: modelImages.count == 1 ? implicitWidth : column.width / 4 - Theme.paddingSmall
                                height: modelImages.count == 1 ? implicitHeight : width
                                source: appUtility.pathPrefix(model.path)
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("SendPage === inserted image clicked" + index);
                                        modelImages.remove(index);
                                        wbSend.setImgPath("");
                                    }
                                    onDoubleClicked: {
                                        console.log("SendPage === inserted image onDoubleClicked")
                                    }
                                }
                            }
                        }
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
    }
}
    
