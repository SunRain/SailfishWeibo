import QtQuick 2.0

import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"
import "../js"
//import "../js/Settings.js" as Settings


Page {
    id: spalashesPage

    property alias _text: label.text

    Label {
        id: label
        width: Math.min(label.implicitWidth, Screen.width)
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
            verticalCenterOffset: -Screen.height/10
        }
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeExtraLarge
//        textFormat: Text.StyledText
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    Label {
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
                        horizontalCenter: parent.horizontalCenter
        }
        color: Theme.secondaryHighlightColor
        text: qsTr("Loading ...")
    }

    SplashesObject {
        id: splashesObject
    }

    BusyIndicator {
        id: busyIndicator
        parent: spalashesPage
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: spalashesPage.status == PageStatus.Active
    }

    Component.onCompleted: {
        var json = splashesObject.splashes;
        var date = new Date();
        var num = date.getTime()%json.lists.length
        _text = JSON.stringify(json.lists[num].splashes);
    }
}
