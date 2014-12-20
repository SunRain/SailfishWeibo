import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id:horizontalIconTextButton

    property bool down: pressed && containsMouse
    property alias text: buttonText.text
    property int fontSize: Math.min(image.width, image.height)
    property bool _showPress: down || pressTimer.running
    property color color: Theme.primaryColor
    property color highlightColor: Theme.highlightColor
    property int spacing: Theme.paddingSmall
    property alias icon: image.source
    property real iconSize: Theme.iconSizeSmall
    //property alias source: image.source

    onPressedChanged: {
        if (pressed) {
            pressTimer.start()
        }
    }
    onCanceled: pressTimer.stop()

    width: image.width + buttonText.width + horizontalIconTextButton.spacing
    height: Math.max(image.height, buttonText.height)

    Timer {
        id: pressTimer
        interval: 50
    }
    Row {
        id: row
        spacing: horizontalIconTextButton.spacing
        Image {
            id:image
            fillMode: Image.PreserveAspectFit
            width: horizontalIconTextButton.iconSize
            height: image.width
        }
        Label {
            id:buttonText
            anchors.verticalCenter: image.verticalCenter
            color: _showPress ? horizontalIconTextButton.highlightColor : horizontalIconTextButton.color
            font.pixelSize: horizontalIconTextButton.fontSize
        }
    }
}
