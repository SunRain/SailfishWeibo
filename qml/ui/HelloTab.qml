import QtQuick 2.0
import Ubuntu.Components 0.1
import aesyweibo 1.0
import "../components"

Tab {
    title: i18n.tr("Hello..")

    page: Page {
        Column {
            spacing: units.gu(2)
            anchors.centerIn: parent

            MyType {
                id: myType

//                Component.onCompleted: {
//                    myType.helloWorld = "Cpp Backend + Tabbed UI"
//                }
            }

            HelloComponent {
                objectName: "helloTab_HelloComponent"

                anchors.horizontalCenter: parent.horizontalCenter

                text: i18n.tr(myType.helloWorld)
            }

            Label {
                objectName: "helloTab_label"

                anchors.horizontalCenter: parent.horizontalCenter

                text: i18n.tr("You can change the Tab from Page title above.")
            }
        }
    }
}
