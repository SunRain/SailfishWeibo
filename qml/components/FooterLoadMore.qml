import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: footerComponent
    anchors { left: parent.left; right: parent.right }
    height: visible ? Theme.itemSizeMedium : 0
    
    signal clicked()

    Item {
        width: parent.width
        height: Theme.itemSizeMedium
        Button {
            anchors.centerIn: parent
            text: qsTr("click here to load more..")
            onClicked: {
                footerComponent.clicked()
            }
        }
    }
}
