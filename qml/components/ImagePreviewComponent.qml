import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtDocGallery 5.0
//import org.nemomobile.thumbnailer 1.0

Item {
    id:imagePreviewComponent
    
    anchors.fill: parent
    
    //signal imageClicked(var model, var index)
    signal imageClicked(var model)
    
    DocumentGalleryModel {
        id: galleryModel
        rootType: DocumentGallery.Image
        properties: [ "url", "title", "dateTaken" ]
        autoUpdate: true
        sortProperties: ["dateTaken"]
    }

    SilicaGridView {
        id: grid
        anchors{
            top:parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingSmall
        
        }
        
        header: PageHeader { title: qsTr("Images") }
        
        cellWidth: (width - Theme.paddingSmall) / 4// - Theme.paddingLarge
        cellHeight: (width - Theme.paddingSmall) / 4// -Theme.paddingLarge

        model: galleryModel


        delegate: Image {
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            // From org.nemomobile.thumbnailer
            source:  "image://nemoThumbnail/" + url

            sourceSize.width: grid.cellWidth
            sourceSize.height: grid.cellHeight
                    
            MouseArea {
                anchors.fill: parent
                onClicked: {
//                    window.pageStack.push(Qt.resolvedUrl("ImagePage.qml"),
//                                                 {currentIndex: index, model: grid.model} )
                    console.log("imagePreviewComponent === onImage clicked" + grid.model.get(index));
                    //imagePreviewComponent.imageClicked(grid.model, index);
                    imagePreviewComponent.imageClicked(grid.model.get(index));
                }
            }
        }
        ScrollDecorator {}
    }
}

