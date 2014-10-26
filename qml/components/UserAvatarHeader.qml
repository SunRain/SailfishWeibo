import QtQuick 2.0
import Sailfish.Silica 1.0

Item{
    id: userAvatarHeader
    
//    property alias width: userAvatarHeader.width
//    property alias height: userAvatarHeader.height
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
                source: model.user.profile_image_url
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
//                    console.log("=== DelegateWeibo usAvatar clicked");
//                    toUserPage(model.user.id)
                    userAvatarClicked();
                }
            }
        }
        
        Column {
            id:rowUserColumn
            spacing: Theme.paddingSmall
            
            Label {
                id: labelUserName
                color: Theme.primaryColor
                text: model.user.screen_name
//                font.pixelSize: Theme.fontSizeExtraSmall
            }
            
            Label {
                id: labelWeiboTime
                color: Theme.secondaryColor
                text: {
                    //                        console.log("appData.dateParse(model.created_at): ", appData.dateParse(model.created_at))
                    //                        var ddd = new Date(appData.dateParse(model.created_at) + "")
                    //                        console.log("ddd: ", ddd.getTime())
                    return DateUtils.formatRelativeTime(/*i18n,*/ DateUtils.parseDate(appData.dateParse(model.created_at)))
                            + qsTr(" From ") + GetURL.linkToStr(model.source)
                }
                font.pixelSize: labelUserName.font.pixelSize*2/3 //Theme.fontSizeTiny 
            }
        }
    }
}
