import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../js/Settings.js" as Settings

Dialog {
    id: dialog

    readonly property bool loginSucced: _loginSucceed
    property string token: ""
    readonly property alias _token: dialog.token
    property bool _loginSucceed: false
    property bool _canAccept: false
    property bool _showLoginView: true

    //只有当登陆成功的时候才能accept
    canAccept: _canAccept


//    DialogHeader {}

    BusyIndicator {
        id: busyIndicator
        parent: dialog
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: !_showLoginView
        opacity: busyIndicator.running ? 1 : 0
    }

    onTokenChanged: {
        _showLoginView = false;
        api.checkToken(_token); //signal onTokenExpired
    }

    Connections {
        target: api
        onTokenExpired: {
            if (!tokenExpired) {
                console.log("==== !tokenExpired")
                api.accessToken = Settings.getAccess_token();
                api.uid = Settings.getUid();
                timer.start();
            } else {
                _showLoginView = true;
            }
        }
    }

    Timer {
        id: timer
        interval: 300
        onTriggered: {
            _canAccept = true;
            _loginSucceed = true;
            dialog.accept();
        }
    }

    LoginComponent {
        id:loginView
        anchors.fill: parent
        opacity: _showLoginView ? 1 : 0
        onLoginSucceed: {
            _canAccept = true;
            _loginSucceed = true;
            dialog.accept();
        }
    }
}
