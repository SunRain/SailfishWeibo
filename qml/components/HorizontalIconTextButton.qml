import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id:horizontalIconTextButton
    width: childrenRect.width
    height: image.height > text.height ? image.height : text.height
    
    property alias source: image.source
    property alias text: text.text
    property alias color: text.color
    
    signal clicked
    Image {
        id:image
    }
    Label {
        id:text
        anchors {
            left: image.right
            leftMargin: Theme.paddingSmall
            verticalCenter: image.verticalCenter
        }
        font.pixelSize: image.width > image.height ? image.height : image.width
    }
    MouseArea {
        anchors.fill: parent
        onClicked: { horizontalIconTextButton.clicked() }
    }
}
