import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL

MouseArea {
    id: baseWeiboCard
    width: parent ? parent.width : Screen.width
    height: isInvalid ? 0 : columnWContent.height

    property var picURLs: undefined
    
    property bool isInvalid: false
    
    property alias avatarHeaderHeight: userAvatarHeader.height
    property alias avaterHeaderFontSize: userAvatarHeader.userNameFontSize
    property alias avaterHeaderUserName: userAvatarHeader.userName
    property alias avaterHeaderAvaterImage: userAvatarHeader.userAvatar
    property alias avaterHeaderWeiboTime: userAvatarHeader.weiboTime
    
    property alias labelFontSize: labelWeibo.font.pixelSize
    property alias labelContent: labelWeibo.text
    
    property alias videoPic: videoImage.source
    property alias optionMenu: optionItem.menu
    
    signal baseWeiboCardClicked
    signal userAvatarHeaderClicked
    signal labelLinkClicked(string link)
    signal labelImageClicked(var modelImages, string index)
    signal videoPicClicked
    
    onPicURLsChanged: {
        calculatePics();
    }
    Component.onCompleted: {
        calculatePics();
    }
    onClicked: {
        baseWeiboCard.baseWeiboCardClicked();
    }

    function calculatePics() {
        if ( !isInvalid && picURLs != undefined && (picURLs.length > 0 || picURLs.count > 0)) {
            modelImages.clear()
//            console.log(" >>>>>> picURLs "+picURLs);
            //picURLs as a json object
            if (picURLs.length > 0) {
                for (var i=0; i<picURLs.length; i++) {
//                    console.log("========  json object "+picURLs[i]);
                    modelImages.append(picURLs[i]);
                }
            } else { //picURLs as a qml list model
                for (var j=0; j<picURLs.count; ++j) {
//                    console.log("========  list model "+picURLs.get(j) + " value " + JSON.stringify(picURLs.get(j)));
                    var value = JSON.stringify(picURLs.get(j))
                    modelImages.append(JSON.parse(value));
                }
            }
            if (gridRepeater.model == undefined) {
                gridRepeater.model = modelImages;
            }
        }
    }
    ListModel { id: modelImages }
    Column {
        id: columnWContent
        width: parent.width
        anchors {
            left: parent.left
            top: parent.top
        }
        spacing: Theme.paddingSmall
        Item {
            id: avatarBar
            width: parent.width
            height: optionItem.height
            
            OptionItem{
                id:optionItem
                UserAvatarHeader {
                    id: userAvatarHeader
                    onUserAvatarClicked: {
                        baseWeiboCard.userAvatarHeaderClicked();
                    }
                }
                onMenuStateChanged: {
                }
            }
        }
        
        Label {
            id: labelWeibo
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: Text.StyledText
            onLinkActivated: {
                baseWeiboCard.labelLinkClicked(link);
            }
        }
        Image {
            id: videoImage
            width: parent.width
            fillMode: Image.PreserveAspectFit
            MouseArea {
                anchors.fill: parent
                onClicked: {videoPicClicked()}
            }
        }
        Grid {
            id: gridWeiboPics
            columns: modelImages.count == 1 ? 1 : 3
            spacing: Theme.paddingSmall
            Repeater {
                id:gridRepeater
                delegate: Component {
                    Image{
                        id:image
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1
                               ? implicitHeight > Screen.height/2 ? Screen.width/2 : implicitWidth
                               : columnWContent.width / 3 - Theme.paddingSmall;
                        height: modelImages.count == 1
                                ? implicitHeight > Screen.height/2 ? Screen.width/2 : implicitHeight
                                : width
                        source: model.thumbnail_pic || model.url
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                baseWeiboCard.labelImageClicked(modelImages, index);
                            }
                        }
                    }
                }
            }
        }
    }
}
