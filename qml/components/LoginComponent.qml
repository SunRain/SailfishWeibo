import QtQuick 2.0
import Sailfish.Silica 1.0

//import "../js/Settings.js" as Settings

Item {
    id:loginComponent
    
    signal loginSucceed()
    
    SilicaFlickable {
        anchors.fill: parent
        
        BusyIndicator {
            id:busyIndicator
            parent: loginComponent
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }
        
        Column {
            id:column
            anchors{
                top:parent.top
                topMargin: Theme.paddingLarge*4
                horizontalCenter: parent.horizontalCenter
            }
            
            spacing: Theme.paddingMedium
            
            PageHeader { 
                title: qsTr("Login")
            }
            
            Rectangle {
                id:rectangle
                width: input.width + Theme.paddingMedium*2
                height: input.height + Theme.paddingMedium*2
                border.color:Theme.highlightColor
                color:"#00000000"
                radius: 30
                Column {
                    id:input
                    anchors{
                        top:rectangle.top
                        topMargin: Theme.paddingMedium
                    }
                    
                    spacing: Theme.paddingMedium
                    
                    TextField {
                        id:userName
                        width:loginComponent.width - Theme.paddingLarge*4
                        height:implicitHeight
                        font.pixelSize: Theme.fontSizeMedium 
                        placeholderText: "Enter Username"
                        label: qsTr("UserName")
                    }
                    TextField {
                        id:password
                        width:loginComponent.width - Theme.paddingLarge*4
                        height:implicitHeight
                        echoMode: TextInput.Password
                        font.pixelSize: Theme.fontSizeMedium 
                        placeholderText: "Enter Password"
                        label: qsTr("Password")
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
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Login")
                onClicked: {
                    errorLabel.visible = false;
                    
                    busyIndicator.running = true;
                    api.username = userName.text;
                    api.password = password.text;
                    api.login();
                }
            }
        }
        
        Label {
            id:errorLabel
            anchors{
                top:column.bottom
                topMargin: Theme.paddingLarge
                bottom: parent.bottom
                bottomMargin: Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            width: column.width
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Theme.fontSizeExtraSmall
        }
        
        Connections {
            target: api
            onLoginSucceed: {
                errorLabel.visible = false;
                busyIndicator.running = false;
                api.accessToken = accessToken;
                api.uid = uid;
//                Settings.setAccess_token(accessToken);
                settings.accessToken = accessToken;
//                Settings.setUid(uid);
                settings.uid = uid;
                loginComponent.loginSucceed();
            }
            onLoginFail: {
                busyIndicator.running = false;
                errorLabel.visible = true;
                errorLabel.text = qsTr("Login fail")+" [ "+fail+" ]. " + qsTr("Please try again.");
            }
        }
        
    }
}
