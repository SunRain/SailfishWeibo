import QtQuick 2.0
import Sailfish.Silica 1.0

Item{
    id: userAvatarHeader
    
    property alias userName: labelUserName.text
    property alias weiboTime: labelWeiboTime.text
    property alias userAvatar: avatarImage.source
    property alias userNameFontSize: labelUserName.font.pixelSize

    signal userAvatarClicked
    
    Row {
        id: rowUser
        spacing: Theme.paddingMedium
        
        anchors{
            left:parent.left
            right:parent.right
            top:parent.top
            bottom: parent.bottom
            margins: Theme.paddingSmall            
        }
        
        Item {
            id: usAvatar
            width: userAvatarHeader.height - Theme.paddingSmall*2
            height: width
            Image {
                id:avatarImage
                width: parent.width
                height: parent.height
                smooth: true
                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    userAvatarClicked();
                }
            }
        }
        
        Column {
            id:rowUserColumn
            spacing: Theme.paddingSmall
            anchors.verticalCenter: usAvatar.verticalCenter
            
            Label {
                id: labelUserName
                color: Theme.primaryColor
            }
            
            Label {
                id: labelWeiboTime
                color: Theme.secondaryColor
                font.pixelSize: labelUserName.font.pixelSize*2/3
            }
        }
    }
}
