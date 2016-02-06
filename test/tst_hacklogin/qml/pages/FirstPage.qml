/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

Page {
    id: page
    WrapperFriendshipsGroups {
        id: wrapperFriendshipsGroups
        onRequestAbort: {
            console.log("=== wrapperFriendshipsGroups onRequestAbort")
        }
        onRequestFailure: { //replyData
            console.log("=== wrapperFriendshipsGroups onRequestFailure " +replyData)
        }
        onRequestSuccess: {
//            retLabel.text = replyData;
            console.log("===== wrapperFriendshipsGroups onRequestSuccess ["+replyData+"]")
        }
    }
    WrapperFriendshipsGroupsTimeline {
        id: wrapperFriendshipsGroupsTimeline
        onRequestAbort: {
            console.log("=== wrapperFriendshipsGroupsTimeline onRequestAbort")
        }
        onRequestFailure: { //replyData
            console.log("=== wrapperFriendshipsGroupsTimeline onRequestFailure " +replyData)
        }
        onRequestSuccess: {
//            console.log("=== wrapperFriendshipsGroupsTimeline onRequestSuccess [" +replyData+"]")
            console.log("=== wrapperFriendshipsGroupsTimeline onRequestSuccess");
        }
    }

    CookieDataProvider {
        id: loginProvider
        onPreLoginSuccess: {
            console.log("===== onPreLoginSuccess");
            image.source = loginProvider.captchaImgUrl;
        }
        onPreLoginFailure: { //str
            console.log("Try hack login failure on prelogin, error code is [" + str +"].");
        }
        onLoginSuccess: {
            console.log("Hack login success");
        }
        onLoginFailure: { //str
            console.log("Try hack login failure [" + str +"]");
        }
    }

    Component.onCompleted: {
        loginProvider.preLogin();
    }

    Flickable {
        id: loginFlickable
//        width: parent.width *0.3
//        anchors {
//            top: parent.top
//            left: parent.left
//            bottom: btnFlickable.top
//        }
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            TextField {
                id: userName
                width: parent.width
                placeholderText: "userName"
            }
            TextField {
                id: password
                width: parent.width
                placeholderText: "password"
            }
            Image {
                id: image
                width: parent.width
                height: Theme.itemSizeSmall
            }
            TextField {
                id: input
                width: parent.width
            }
            Button {
                text: "login"
                onClicked: {
                    loginProvider.captcha = input.text;
                    loginProvider.userName = userName.text;
                    loginProvider.passWord = password.text;
                    loginProvider.login();
                }
            }
            TextSwitch {
                id: hackLoginCheck
                width: parent.width
                checked: tokenProvider.useHackLogin
                text: "use hacklogin"
                onCheckedChanged: {
                    console.log("=== onCheckedChanged " +hackLoginCheck.checked);
                    tokenProvider.useHackLogin = hackLoginCheck.checked;
                }
            }
            Button {
                text: "groups"
                onClicked: {
                    wrapperFriendshipsGroups.getRequest();
                }
            }
            Row {
                TextField {
                    id: groupGid
                    width: parent.width/2
                    placeholderText: "Group(gid number)"
                }
                Button {
                    text: "view "
                    onClicked: {
                        wrapperFriendshipsGroupsTimeline.setParameters("gid", groupGid.text)
                        wrapperFriendshipsGroupsTimeline.getRequest();
                    }
                }
            }
        }
    }
//    Flickable {
//        id: flickable
//        anchors {
//            top: parent.top
//            left: loginFlickable.right
//            right: parent.right
//            bottom: btnFlickable.top
//        }
//        contentHeight: retLabel.height
//        Label {
//            id: retLabel
//            //                font.pixelSize: 16
//            //            font.italic: true
//            color: "steelblue"
//            width: parent.width
//            wrapMode: Text.WrapAnywhere
//        }
//    }
//    Flickable {
//        id: btnFlickable
//        anchors {
//            left: parent.left
//            right: parent.right
//            bottom: parent.bottom
//        }
//        height: btnRow.height
//        contentWidth: btnRow.width
//        Row {
//            id: btnRow
//            Button {
//                text: "groups"
//                onClicked: {
//                    wrapperFriendshipsGroups.getRequest();
//                }
//            }
//            Column {
//                TextField {
//                    id: groupGid
//                    placeholderText: "Group(gid number)"
//                }
//                Button {
//                    text: "view "
//                    onClicked: {
//                        wrapperFriendshipsGroupsTimeline.setParameters("gid", groupGid.text)
//                        wrapperFriendshipsGroupsTimeline.getRequest();
//                    }
//                }
//            }

//        }
//    }
}


