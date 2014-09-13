import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1

Item {
    id: footerComponent
    anchors { left: parent.left; right: parent.right }
    height: visible ? units.gu(7) : 0

    signal clicked()

    Label {
        anchors.centerIn: parent
        text: i18n.tr("click here to load more..")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: footerComponent.clicked()
    }
}
