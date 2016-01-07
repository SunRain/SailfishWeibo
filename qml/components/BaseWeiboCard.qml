import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL

Item {
    id:baseWeiboCard
    anchors { left: parent.left; right: parent.right }
    height: isInvalid ? 0 : columnWContent.height + Theme.paddingMedium

    property var picURLs:undefined
    
    property bool isInvalid: false
    
    property alias avatarHeaderHeight: userAvatarHeader.height
    property alias avaterHeaderFontSize: userAvatarHeader.userNameFontSize
    property alias avaterHeaderUserName: userAvatarHeader.userName
    property alias avaterHeaderAvaterImage: userAvatarHeader.userAvatar
    property alias avaterHeaderWeiboTime: userAvatarHeader.weiboTime
    
    property alias labelFontSize: labelWeibo.font.pixelSize
    property alias labelContent: labelWeibo.text
    
    property alias optionMenu: optionItem.menu
    
    signal baseWeiboCardClicked
    signal userAvatarHeaderClicked
    signal labelLinkClicked(string link)
    signal labelImageClicked(var modelImages, string index)
    
    
    Component.onCompleted: {
        if ( !isInvalid && picURLs != undefined && (picURLs.length > 0 || picURLs.count > 0)) {
            modelImages.clear()
            //picURLs as a json object
            if (picURLs.length > 0) {
                for (var i=0; i<picURLs.length; i++) {
                    modelImages.append( picURLs[i] )
                }
            } else { //picURLs as a qml list model
//                console.log("======== picURLs.count " + picURLs.count);
//                console.log(" *** avaterHeaderUserName " + avaterHeaderUserName);
                for (var i=0; i<picURLs.count; i++) {
                    var value = JSON.stringify(picURLs.get(i))
//                    console.log(" >>>>> " + value + " <<<< ")
                    modelImages.append( JSON.parse(value) )
                }
            }

            if (gridRepeater.model == undefined) {
                gridRepeater.model = modelImages;
            }
        } 
    }
    
    ListModel { id: modelImages }

    MouseArea {
        anchors.fill: parent
        onClicked: { baseWeiboCard.baseWeiboCardClicked(); }
    }
    
    Column {
        id: columnWContent
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingSmall
            rightMargin:Theme.paddingSmall
        }
        spacing: Theme.paddingSmall
        
        Item {
            id: avatarBar
            width: columnWContent.width
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
//                    console.log("====== option Item " + menuOpen);
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

        Grid {
            id: gridWeiboPics
            columns: 3
            spacing: Theme.paddingSmall
            Repeater {
                id:gridRepeater
//                model: ListModel { id: modelImages }
                delegate: Component {
                    Image{
                        id:image
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - Theme.paddingSmall;
                        height: modelImages.count == 1 ? implicitHeight : width
                        source: util.parseImageUrl(model.thumbnail_pic);

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                baseWeiboCard.labelImageClicked(modelImages, index);
                            }
                        }
                        
                        onStatusChanged: {
                            if(image.status == Image.Ready) {
                                util.saveRemoteImage(model.thumbnail_pic);
                            }
                        }
                    }
                }
            }
        }
    }
}
