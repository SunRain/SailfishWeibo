import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

SilicaFlickable {
    id: loginComponent
    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height
    contentHeight: column.height

    signal loginSucceed

    ScrollDecorator{}

    CookieDataProvider {
        id: cookie
        onPreLoginSuccess: {
            captchaImg.source = cookie.captchaImgUrl;
            captchaImg.visible = true;
            captchaImg.enabled = true;
        }
        onPreLoginFailure: { //str
            errorLabel.visible = true
            errorLabel.text = qsTr("Try hack login failure on prelogin, error code is") + "[" + str +"]."
        }
        onLoginSuccess: {
            busyIndicator.running = false;
            loginComponent.loginSucceed()
        }
        onLoginFailure: { //str
            errorLabel.visible = true
            busyIndicator.running = false;
            errorLabel.text = qsTr("Try hack login failur") + " [" + str +"]";
        }
        onCaptchaImgUrlChanged: {
            captchaImg.source = cookie.captchaImgUrl;
        }
    }

    Component.onCompleted: {
        cookie.preLogin();
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }
    Column {
        id: column
        anchors{
            top: parent.top
            topMargin: Theme.paddingLarge * 4
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Theme.paddingMedium
        PageHeader {
            title: qsTr("Login")
        }
        Rectangle {
            id: rectangle
            width: input.width + Theme.paddingMedium*2
            height: input.height + Theme.paddingMedium*2
            border.color:Theme.highlightColor
            color:"#00000000"
            radius: 30
            Column {
                id:input
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingMedium
                spacing: Theme.paddingMedium
                TextField {
                    id: userName
                    width: loginComponent.width - Theme.horizontalPageMargin * 4
                    inputMethodHints:Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                    font.pixelSize: Theme.fontSizeMedium
                    placeholderText: qsTr("Enter e-mail or username")
                    label: qsTr("UserName")
                    EnterKey.enabled: text || inputMethodComposing
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: password.focus = true
                }
                TextField {
                    id: password
                    width:loginComponent.width - Theme.horizontalPageMargin * 4
                    echoMode: TextInput.Password
                    font.pixelSize: Theme.fontSizeMedium
                    placeholderText: "Enter Password"
                    label: qsTr("Password")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: {
                        if (captchaImg.visible)
                            submitButton.focus
                        else
                            cap.focus = true
                    }
                }
                Image {
                    id: captchaImg
                    width: parent.width *0.8
                    height: Theme.itemSizeSmall
                    x: Theme.horizontalPageMargin
                    fillMode: Image.PreserveAspectFit
                    visible: false;
                    enabled: false;
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            cookie.preLogin();
                        }
                    }
                }
                TextField {
                    id: cap
                    width: loginComponent.width - Theme.horizontalPageMargin *4
                    visible: captchaImg.visible
                    enabled: captchaImg.visible
                    font.pixelSize: Theme.fontSizeMedium
                    placeholderText: qsTr("Enter captcha")
                    label: qsTr("Captcha")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: {
                        submitButton.focus = true
                    }
                }
            }
        }
        TextSwitch {
            text: qsTr("Show Password")
            onCheckedChanged: {
                checked ? password.echoMode = TextInput.Normal
                        : password.echoMode = TextInput.Password
            }
        }
        Button {
            id: submitButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Login")
            enabled: userName.text && password.text && (captchaImg.enabled && cap.text)
            onClicked: {
                errorLabel.visible = false;
                cookie.userName = userName.text;
                cookie.passWord = password.text;
                cookie.captcha = cap.text;
                busyIndicator.running = true;
                cookie.login();
            }
        }
        Label {
            id: errorLabel
            width: parent.width - Theme.horizontalPageMargin * 2
            x: Theme.horizontalPageMargin
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }
}
