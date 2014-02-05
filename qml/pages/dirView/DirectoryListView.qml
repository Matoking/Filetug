import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../js/directoryViewModel.js" as DirectoryViewModel
import "../../js/misc.js" as Misc

SilicaListView {
    id: fileListView

    property bool isDirectoryView: true

    property variant directoryView: null

    property bool destroyAfterTransition: false

    property string path: ""

    width: parent.width
    height: parent.height

    currentIndex: engine.currentFileIndex

    VerticalScrollDecorator { }

    // Directory title header
    header: Item {
        anchors.left: parent.left
        anchors.right: parent.right

        height: Theme.itemSizeLarge

        Label {
            id: headerLabel

            text: settings.dirPath

            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge

            color: Theme.highlightColor

            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter

            height: settings.showDirHeader == true ? Theme.itemSizeLarge : 0

            visible: settings.showDirHeader
        }
        OpacityRampEffect {
            direction: OpacityRamp.RightToLeft
            slope: 4
            offset: 0.75
            sourceItem: headerLabel
        }
    }

    model: fileModel

    delegate: Component {
        id: listItem

        IconButton {
            id: iconButton
            width: fileListView.width
            height: Screen.height / 12

            Image {
                id: image
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: height

                source: model.thumbnail

                onStatusChanged: {
                    iconButton.down = clipboard.selectedFilesContainsFile(model.fullPath)
                }
            }
            Label {
                id: fileNameLabel

                anchors.left: image.right
                anchors.leftMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.top: parent.top
                anchors.topMargin: 5

                text: model.fileName
            }

            Rectangle {
                anchors.fill: parent
                opacity: iconButton.down == true || iconButton.pressed == true ? 0.5 : 0
                color: selectingItems == true ? Theme.highlightColor : Theme.secondaryHighlightColor
            }

            OpacityRampEffect {
                direction: OpacityRamp.LeftToRight
                slope: 4
                offset: 0.75
                sourceItem: fileNameLabel
            }

            Text {
                anchors.left: image.right
                anchors.leftMargin: 5
                anchors.top: fileNameLabel.bottom
                anchors.topMargin: 2

                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor

                text: model.fileType != "directory" ? fileInfo.bytesToString(model.fileSize) : ""
            }

            onClicked: {
                if (!selectingItems)
                    DirectoryViewModel.openFile(model)
                else
                {
                    if (model.fileName == "..")
                        return

                    if (!iconButton.down)
                        clipboard.addFileToSelectedFiles(model.fullPath)
                    else
                        clipboard.removeFileFromSelectedFiles(model.fullPath)

                    iconButton.down = !iconButton.down
                }
            }

            onPressAndHold: {
                if (!selectingItems)
                {
                    getDirectoryPage().selectFiles(true)
                    clipboard.addFileToSelectedFiles(model.fullPath)

                    iconButton.down = true
                }
            }

            Connections {
                target: clipboard
                onSelectedFilesCleared: {
                    iconButton.down = false
                }
                onFileOperationChanged: {
                    iconButton.down = false
                }
            }
        }
    }

    SmoothedAnimation {
        id: animateCollapseLeft
        target: fileListView
        properties: "x"
        from: fileListView.x
        to: fileListView.x - fileListView.width
        duration: 200
        onStopped: if (destroyAfterTransition) fileListView.destroy()
    }

    SmoothedAnimation {
        id: animateCollapseRight
        target: fileListView
        properties: "x"
        from: fileListView.x
        to: fileListView.x + fileListView.width
        duration: 200
        onStopped: if (destroyAfterTransition) fileListView.destroy()
    }

    ListModel {
        id: fileModel
    }

    onPathChanged: {
        DirectoryViewModel.updateFileList(fileModel, path)
    }

    function removeSelections()
    {
        for (var i=0; i < fileListView.children.length; i++)
        {
            var item = fileListView.children[i]

            item.listItem.iconButton.down = false
        }
    }

    function collapseToLeft(destroyAfterCollapse)
    {
        animateCollapseLeft.start()
        destroyAfterTransition = destroyAfterCollapse
    }

    function collapseToRight(destroyAfterCollapse)
    {
        animateCollapseRight.start()
        destroyAfterTransition = destroyAfterCollapse
    }
}
