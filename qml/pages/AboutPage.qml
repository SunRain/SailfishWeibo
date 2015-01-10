import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

Dialog {
    id: aboutpage
        
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + optionItem.height + Theme.paddingMedium *4

        Column {
            id:column
            spacing: Theme.paddingSmall
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingLarge
                rightMargin: Theme.paddingLarge
            }

            PageHeader {
                title: qsTr("About Sailfish Weibo")
            }

            Label {
                id:aboutWeibo
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                wrapMode: Text.Wrap
                text: qsTr("Sailfish Weibo")
            }

            Label {
                id: version
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: qsTr("version") + " " + util.getVerison
            }
            
            //author info
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: qsTr("Author:wanggjghost")//作者:wanggjghost(泪の单翼天使)
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: qsTr("E-mail:41245110@qq.com")//作者:wanggjghost(泪の单翼天使)
            }
            
            Label {
                id: donate
                width: parent.width
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: qsTr("Please donate to alipay wanggjghost@126.com(**健) if U like this app")
                //如果你喜欢本项目的话，给我买瓶啤酒喝好不;)
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("SourceCode")
                onClicked: {
                    openUrl("https://github.com/SunRain/SailfishWeibo");
                }
            }
            
            Separator {
                width:parent.width;
                color: Theme.highlightColor
            }
            
            ////////////////// Credit
            Label {
                id:creditLabel
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                text: qsTr("Credit")
            }

            //////////////// ubuntu touch weibo
            Label {
                id:fineDayLabel
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("UbuntuTouch Weibo")
            }
            
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: qsTr("Author:Joey_Chan")
            }
            
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("SourceCode")
                onClicked: {
                    openUrl("http://bbs.qter.org/forum.php?mod=viewthread&tid=1035&extra=page%3D1%EF%BC%89");
                }
            }

            /////////////////////////// BlackLight
            Separator {
                anchors.horizontalCenter: parent.horizontalCenter
                width:parent.width/2;
                color: Theme.highlightColor
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("BlackLight Weibo")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("SourceCode")
                onClicked: {
                    openUrl("https://github.com/PaperAirplane-Dev-Team/BlackLight");
                }
            }

            //////////////////////////// WangBin
            Separator {
                anchors.horizontalCenter: parent.horizontalCenter
                width:parent.width/2;
                color: Theme.highlightColor
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("WangBin")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Github")
                onClicked: {
                    openUrl("https://github.com/wang-bin");
                }
            }

            ///////////////
            Separator {
                width:parent.width;
                color: Theme.highlightColor
            }
        }
        ////////////////// settings
        OptionItem {
            id:optionItem
            anchors {
                left: parent.left
                right: parent.right
                top: column.bottom
                margins: Theme.paddingMedium
            }

            Label {
                width: parent.width
                color: Theme.primaryColor
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Theme.fontSizeMedium
                text:qsTr("Cache: ") + util.getCachePath
            }

            menu: contextMenu
            ContextMenu {
                id:contextMenu
                MenuItem {
                    text: qsTr("DeleteCache")
                    onClicked: {
                        remorse.execute(optionItem, qsTr("Deleting"), function() {
                            util.deleteDir(util.getCachePath)
                        });
                    }
                }
            }
            RemorseItem { id: remorse }
        }
    }
    
    function openUrl(url) {
        Qt.openUrlExternally(url)
    }
}
