import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../js/Settings.js" as Settings

Page {
    id: loginPage

    signal logined

    LoginComponent {
        id:loginView
        anchors.fill: parent
        onLoginSucceed: {logined();}
    }
}
