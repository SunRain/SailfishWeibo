import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: aboutpage
        
    SilicaFlickable {
        anchors.fill: parent
        
        contentHeight: column.height
        //contentWidth: column.width
        
        Column {
            id:column
            PageHeader {
                title: qsTr("About Sailfish Weibo")
            }

            spacing: Theme.paddingSmall

            width: parent.width

            //header
            Item {
                height: aboutWeibo.height
                anchors { 
                    left: parent.left
                    right: parent.right 
                }
                Label {
                    id:aboutWeibo
                    anchors{
                        centerIn: parent
                    }
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeHuge
                    wrapMode: Text.Wrap
                    text: qsTr("Sailfish Weibo")
                }
            }
            
            //author info
            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width - (2 * Theme.paddingLarge)
                wrapMode: Text.Wrap
                text: qsTr("Author:wanggjghost")//作者:wanggjghost(泪の单翼天使)
            }
            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                width: parent.width - (2 * Theme.paddingLarge)
                text: qsTr("E-mail:41245110@qq.com")//作者:wanggjghost(泪の单翼天使)
            }
            
            BackgroundItem {
                //id: clickableUrl
                contentHeight: authorGithub.height
                height: contentHeight
                width: parent.width
                anchors {
                    left: parent.left
                }
                Label {
                    id: authorGithub
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                    }
                    wrapMode: Text.Wrap
                    width: parent.width - (2 * Theme.paddingLarge)
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Github: https://github.com/SunRain/SailfishWeibo")
                    color: authorGithub.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    openUrl("https://github.com/SunRain/SailfishWeibo");
                }
            }
            
            Separator {
                width:parent.width;
                color: Theme.highlightColor
            }
            
            //credit label
            Item {
                height: creditLabel.height
                anchors { 
                    left: parent.left
                    right: parent.right 
                }
                Label {
                    id:creditLabel
                    anchors{
                        centerIn: parent
                    }
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    text: qsTr("Credit")
                }
            }
            
            //FineDay
            Item{
                height: fineDayLabel.height
                anchors { 
                    left: parent.left
                    right: parent.right 
                }
                Label {
                    id:fineDayLabel
                    anchors{
                        centerIn: parent
                    }
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    text: qsTr("UbuntuTouch Weibo")
                }
            }
            
            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width - (2 * Theme.paddingLarge)
                wrapMode: Text.Wrap
                text: qsTr("Author:Joey_Chan")
            }
            
            BackgroundItem {
                //id: clickableUrl
                contentHeight: finedayGithub.height
                height: contentHeight
                width: parent.width
                anchors {
                    left: parent.left
                }
                Label {
                    id: finedayGithub
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                    }
                    wrapMode: Text.Wrap
                    width: parent.width - (2 * Theme.paddingLarge)
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("http://bbs.qter.org/forum.php?mod=viewthread&tid=1035&extra=page%3D1%EF%BC%89")
                    color: finedayGithub.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    openUrl("http://bbs.qter.org/forum.php?mod=viewthread&tid=1035&extra=page%3D1%EF%BC%89");
                }
            }
        }
    }
    
    function openUrl(url) {
        Qt.openUrlExternally(url)
    }
}
