import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: wbPage
    property alias contentItem: item

    default property alias content: item.data
    Item {
        id: item
        anchors.fill: parent
    }
}
