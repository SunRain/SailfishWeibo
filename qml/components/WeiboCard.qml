import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL

Item {
    id:weiboCard
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
    
    signal weiboCardClicked
    signal userAvatarHeaderClicked
    signal labelLinkClicked(string link)
    signal labelImageClicked(var modelImages, string index)
    
    
    Component.onCompleted: {
        if ( !isInvalid && picURLs != undefined && picURLs.length > 0) {
            modelImages.clear()
            for (var i=0; i<picURLs.length; i++) {
                modelImages.append( picURLs[i] )
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: { weiboCard.weiboCardClicked(); }
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
            width: columnWContent.width
            height: optionItem.menuOpen ? userAvatarHeader.height + optionItem.height : userAvatarHeader.height
            
            UserAvatarHeader {
                id: userAvatarHeader
                width: parent.width *7/10
                onUserAvatarClicked: {
                    weiboCard.userAvatarHeaderClicked();
                }
            }
            OptionItem{
                id:optionItem
                anchors{ left: userAvatarHeader.right; right: parent.right; }
                visible: optionMenu != null
                Image {
                    anchors{
                        top:parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }
                    width: Theme.iconSizeMedium
                    height: width
                    source: optionItem.menuOpen ? 
                                "../graphics/action_collapse.png" : 
                                "../graphics/action_open.png"
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
                weiboCard.labelLinkClicked(link);
            }
        }

        Grid {
            id: gridWeiboPics
            columns: 3
            spacing: Theme.paddingSmall

            Repeater {
                model: ListModel { id: modelImages }
                delegate: Component {
                    Image{
                        id:image
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - Theme.paddingSmall;
                        height: modelImages.count == 1 ? implicitHeight : width
                        source: util.parseImageUrl(model.thumbnail_pic)

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                weiboCard.labelImageClicked(modelImages, index);
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
