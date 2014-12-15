import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Panel {
    id: panel

    //anchors.fill: parent

    signal clicked
    HorizontalIconTextButton {
        id: icon

        spacing: Theme.paddingMedium
        icon: "../graphics/toolbarIcon@8.png"
        iconSize: Theme.itemSizeMedium
        text: "testIcon"

        onClicked: {
            console.log("===== index NavigationPanel clicked")
            clicked();
        }
    }


}
