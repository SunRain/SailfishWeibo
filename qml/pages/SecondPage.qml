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

//import "../js/Settings.js" as Settings
import "../components"
Page {
    id: mainPage

    ListModel {
        id: pagesModel

        ListElement {
            title: "Message"
            page:"../ui/MessageTab.qml"
            arg:""
        }
//        ListElement {
//            title: "Friends"
//        }
        ListElement {
            title: "UserPage"
            //page:"../ui/UserPage.qml"
            arg:"getUid"
        }
        ListElement {
            title: "About"
            page:"AboutPage.qml"
        }
//        ListElement {
//            title: "UserPhoto"
//        }
//        ListElement {
//            title: "Settings"
//        }
        
    }
    
    SilicaFlickable {
        id:silicaFlickable
        anchors.fill: parent
        
        contentHeight: column.height

        Column {
            id:column
            
            anchors{
                left: parent.left
                leftMargin: Theme.paddingMedium
                right: parent.right
                rightMargin: Theme.paddingMedium
            }
            
            PageHeader { 
                title: qsTr("Sailfish Weibo")
            }
            
            spacing: Theme.paddingSmall
            
            Item {
                width: parent.width
                height: listView.height
                
                SilicaListView {
                    id: listView
                    width: parent.width
                    height: contentItem.childrenRect.height
                    model: pagesModel
                    delegate: BackgroundItem {
                        width: parent.width
                        Label {
                            text: qsTr(model.title)
                            color: highlighted ? Theme.highlightColor : Theme.primaryColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        onClicked: {
                            console.log("click item " + title + "with targe " + page + " arg " + arg);
                            if (arg == "getUid") {
                                //pageStack.push(Qt.resolvedUrl(page))
                                var uid = settings.uid; //Settings.getUid();
                                wbFunc.toUserPage(uid);
                            } else {
                                pageStack.push(Qt.resolvedUrl(page))
                            }
                        }
                    }
                }
            }
            
            Separator {
                width: parent.width
                color: Theme.highlightColor
            }

            OptionItem {
                id:optionItem
                width: parent.width
                Label {
                    width: parent.width
                    color: Theme.primaryColor
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text:qsTr("Cache: ") + appUtility.getCachePath
                }

                menu: contextMenu
                ContextMenu {
                    id:contextMenu
                    MenuItem {
                        text: qsTr("DeleteCache")
                        onClicked: {
                            remorse.execute(/*optionItem, */"Deleting", function() {
                                appUtility.deleteDir(appUtility.getCachePath)
                            });
                        }
                    }
                }
                RemorsePopup { id: remorse }
            }
        }
    }
}











