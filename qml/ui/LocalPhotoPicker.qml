import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Qt.labs.folderlistmodel 1.0

Page {
    id: localPhotoPicker
//    title: i18n.tr("Select photo")
    flickable: null
    anchors.fill: parent

    property string folderPath: ""
    property string imgPath: ""

    signal imgPicked(string filePath)

    Component.onCompleted: {
        folderPath = networkHelper.imgFolder
    }

    tools: ToolbarItems {
        id: toolbarPhotoPicker

        ToolbarButton {
            action: Action {
                text:  i18n.tr("Up")
                iconSource: Qt.resolvedUrl("../graphics/up.png")
                onTriggered: {
                    // TODO: go to parent folder
                    console.log("modelFolder.parentPath: ", modelFolder.parentFolder)
                    folderPath = modelFolder.parentFolder
                } // onTriggered
            }
        }

//        ToolbarButton {
//            action: Action {
//                text:  i18n.tr("test")
//                iconSource: Qt.resolvedUrl("../graphics/up.png")
//                onTriggered: {
//                    mainView.addNotification(modelFolder.get(0, "filePath"), 99)
//                } // onTriggered
//            }
//        }
    }

    Timer {
        id: timerPop
        interval: 100; running: false; repeat: false; triggeredOnStart: false
        onTriggered: {
//            PopupUtils.close(componentPreviewSheet)
            imgPicked(imgPath)
            pageStack.pop()
        }
    }

    //////////////////////////////////////////////////////////////////         file model
    FolderListModel {
        id: modelFolder
        folder: folderPath
        nameFilters: ["*.jpg", "*.jpeg", "*.JPG", "*.JPEG", "*.PNG", "*.png", "*.gif", "*.GIF"]
    }

    //////////////////////////////////////////////////////////////////         photo gridview
    GridView {
        id: gvPhoto
        anchors.fill: parent
        anchors.margins: units.gu(1)
        cellWidth: width / 3
        cellHeight: cellWidth
        model: modelFolder
        delegate: delegatePhoto
    }

    //////////////////////////////////////////////////////////////////         delegate
    Component {
        id: delegatePhoto
//        UbuntuShape {
//            id: usPhoto
////            anchors.fill: parent
////            anchors.margins: units.gu(1)
////            anchors.centerIn: delegatePhoto
//            width: gvPhoto.cellWidth - units.gu(0.5)
//            height: width
//            radius: "medium"
//            image: Image {
//                asynchronous: true
//                fillMode: Image.PreserveAspectCrop
//                source: fileIsDir ? "" : filePath
//                sourceSize.width: usPhoto.width
//            }
//        }

        Image {
            width: gvPhoto.cellWidth - units.gu(1)
            height: width
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: fileIsDir ? Qt.resolvedUrl("../graphics/folder.png") : filePath
            sourceSize.width: width

            Label {
                anchors.bottom: parent.bottom
                anchors.margins: units.gu(0.5)
                width: parent.width
                elide: Text.ElideRight
                text: fileName
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (fileIsDir) {
                        folderPath = filePath
                    }
                    else {
                        imgPath = filePath
//                        PopupUtils.open(componentPreviewSheet)
//                        pageStack.pop()
//                        timerPop.start()
//                        var sheet = componentPreviewSheet.createObject(localPhotoPicker)
                        loaderPreview.sourceComponent = componentPreviewSheet
                    }
                }
            }
        }
    }

    //////////////////////////////////////////////////////////////////         Popup "Preview"
    Loader {
        id: loaderPreview
        anchors.fill: parent
        sourceComponent: undefined
    }

    Component {
        id: componentPreviewSheet

        Rectangle {
            id: sheetPreview
            color: "black"
//            contentsHeight: parent.height
//            contentsWidth: parent.width

//            signal imgPicked()

//            onCancelClicked: PopupUtils.close(sheetPreview)
//            onConfirmClicked: {
////                sheetPreview.imgPicked()
//                timerPop.start()
////                mainStack.currentPage.destroy()
//            }

            //////////////////////////////////////////////////////////////////         header
            Rectangle {
                id: recHeader
                anchors { left: parent.left; right: parent.right }
                height: btnCancel.height + units.gu(2)
                color: Qt.rgba(255, 255, 255, 0.2)

                Label {
                    id: labelTitle
                    anchors.centerIn: parent
                    fontSize: "large"
                    color: "white"
                    text: i18n.tr("Preview")
                }

                Button{
                    id: btnCancel
                    anchors {
                        left: parent.left; leftMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    gradient: UbuntuColors.greyGradient
                    text: i18n.tr("Cancel")

                    onClicked: {
                        loaderPreview.sourceComponent = undefined
                    }
                }

                Button{
                    id: btnSend
                    anchors {
                        right: parent.right; rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    text: i18n.tr("Confirm")

                    onClicked: {
                        imgPicked(imgPath)
                        pageStack.pop()
                    }
                }
            }

            Flickable {
                id: scrollArea
                boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
                anchors {
                    top: recHeader.bottom;  topMargin: units.gu(1)
                    left: parent.left; right: parent.right
//                    leftMargin: units.gu(1); rightMargin: units.gu(1)
                    bottom: parent.bottom
                }
                contentWidth: imgPreview.width
                contentHeight: imgPreview.height/* + units.gu(2)*/

                Image {
                    id: imgPreview
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: imgPath
                    sourceSize.width: scrollArea.width
                    sourceSize.height: scrollArea.height

                    onStatusChanged: {
                        if (status == Image.Ready) {
                            var xx = (scrollArea.width - imgPreview.implicitWidth) / 2
                            var yy = (scrollArea.height - imgPreview.implicitHeight) / 2
                            imgPreview.x = xx >= 0 ? xx : 0
                            imgPreview.y = yy >= 0 ? yy : 0
                        }
                    }
                }

            }

        }
    }// component
}
