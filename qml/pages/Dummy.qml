import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dummy

    Item {
        width: parent.width
        height: parent.width

        Label {
            anchors.centerIn: parent
            text: qsTr("Comming Soon")
            font.pixelSize: Theme.fontSizeHuge
            color: Theme.highlightColor
        }
    }
}
