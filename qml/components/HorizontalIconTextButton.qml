import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id:horizontalIconTextButton

    property bool down: pressed && containsMouse
    property alias text: buttonText.text
    property int fontSize: horizontalIconTextButton.height
    property bool _showPress: down //|| pressTimer.running
    property color color: Theme.primaryColor
    property color highlightColor: Theme.highlightColor
    property int spacing: Theme.paddingSmall
    property alias icon: image.source
    property real iconSize: Theme.iconSizeSmall
    property real dotOpacity: 0
    //property alias source: image.source

//    onPressedChanged: {
//        if (pressed) {
//            pressTimer.start()
//        }
//    }
//    onCanceled: pressTimer.stop()

    width: parent ? parent.width : Screen.width//image.width + buttonText.width + horizontalIconTextButton.spacing
    height: parent ? parent.height : Theme.itemSizeExtraSmall //Math.max(image.height, buttonText.height)

//    Timer {
//        id: pressTimer
//        interval: 50
//    }

    Image {
        id:image
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        fillMode: Image.PreserveAspectFit
        width: image.height
        height: Math.min(horizontalIconTextButton.height, horizontalIconTextButton.iconSize)
    }
    Label {
        id:buttonText
        anchors{
            left: image.right
            leftMargin: horizontalIconTextButton.spacing
            right: parent.right
            verticalCenter: image.verticalCenter
        }
        elide: Text.ElideRight
        color: _showPress ? horizontalIconTextButton.highlightColor : horizontalIconTextButton.color
        font.bold: _showPress
        font.pixelSize: Math.min(horizontalIconTextButton.fontSize, horizontalIconTextButton.height)
    }

    Rectangle {
        radius: 90
        anchors {
            left: parent.left
            leftMargin: parent.iconSize
            top: parent.top
            topMargin: horizontalIconTextButton.height - horizontalIconTextButton.fontSize
        }
        enabled: horizontalIconTextButton.dotOpacity > 0
        width: horizontalIconTextButton.height - horizontalIconTextButton.fontSize
        height: width
        z: parent.z + 1
        color: Theme.highlightColor
        opacity: horizontalIconTextButton.dotOpacity
    }
}
