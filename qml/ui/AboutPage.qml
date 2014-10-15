import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Dialog {
    id: dialogue
    width: parent.width
    title: i18n.tr("About AesyWeibo")
//            text: i18n.tr("Please choose one of the following options")

    Item {
        width: units.gu(20)
        height: units.gu(8)

        Image {
            id: appIcon
            anchors.horizontalCenter: parent.horizontalCenter
            source: Qt.resolvedUrl("../aesyweibo.png")
            sourceSize.width: units.gu(10)  //parent.width / 4
            sourceSize.height: units.gu(10)
        }
    }

//            Label {
//                anchors.horizontalCenter: parent.horizontalCenter
//                text: i18n.tr("AesyWeibo")
//                fontSize: "large"
//            }

    Item{ height: units.gu(2); width: 2 }

    Label {
        text: i18n.tr("Sina Weibo client for Ubuntu Touch")
    }

    ListItem.ThinDivider{}

    Label {
        text: i18n.tr("This software is open source under GPLv3")
    }

    ListItem.ThinDivider{}

    Label {
        text: i18n.tr("<a>https://code.google.com/p/ubuntu-touch-weibo/</a>")
    }

    ListItem.ThinDivider{}

    Label {
        text: i18n.tr("Author: Joey Chan")
    }

    ListItem.ThinDivider{}

    Label {
        text: i18n.tr("Email: joeychan.ubuntu@gmail.com")
    }

    ListItem.ThinDivider{}

    Button{
//                gradient: UbuntuColors.greyGradient
        text: i18n.tr("Close")
        onClicked: PopupUtils.close(dialogue)
    }
}

//Page {
//    id: userPhoto
////    flickable: null
//    title: i18n.tr("About AesyWeibo")

//    Rectangle{
//        anchors.fill: parent
//        color: "black"
//    }

//    Flickable {
//        id: scrollArea
//        boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
//        anchors.fill: parent
//        contentWidth: width
//        contentHeight: innerAreaColumn.height/* + units.gu(2)*/

//        Column {
//            id: innerAreaColumn

//            spacing: units.gu(1)
//            anchors {
//                top: parent.top;
//                //                topMargin: units.gu(1)
//                margins: units.gu(1)
//                left: parent.left; right: parent.right
//                //                leftMargin: units.gu(1); rightMargin: units.gu(1)
//            }
//            height: childrenRect.height

//            Image {
//                id: appIcon
//                anchors.horizontalCenter: parent.horizontalCenter
//                source: Qt.resolvedUrl("../aesyweibo.png")
//                sourceSize.width: parent.width / 3
////                sourceSize.height: sourceSize.width
//            }

//            Label {
//                anchors.horizontalCenter: parent.horizontalCenter
//                text: i18n.tr("AesyWeibo")
//                fontSize: "large"
//            }

//            Item{ height: units.gu(2); width: 2 }

//            Label {
//                text: i18n.tr("Sina Weibo client for Ubuntu Touch")
//            }

//            ListItem.ThinDivider{}

//            Label {
//                text: i18n.tr("This software is open source under GPLv3")
//            }

//            ListItem.ThinDivider{}

//            Label {
//                text: i18n.tr("<a>https://code.google.com/p/ubuntu-touch-weibo/</a>")
//            }

//            ListItem.ThinDivider{}

//            Label {
//                text: i18n.tr("Author: Joey Chan")
//            }

//            ListItem.ThinDivider{}

//            Label {
//                text: i18n.tr("Email: joeychan.ubuntu@gmail.com")
//            }

//            ListItem.ThinDivider{}
//        }
//    }
//}
