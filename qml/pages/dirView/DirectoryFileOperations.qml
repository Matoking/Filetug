import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: item

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    Label {
        id: clipboardLabel

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right

        color: Theme.secondaryColor

        visible: false

        text: ""
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        height: visible == true ? Theme.itemSizeSmall : 0
        width: parent.width
    }
    IconButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge

        width: clipboardLabel.visible == true ? Theme.itemSizeSmall : 0
        height: clipboardLabel.visible == true ? Theme.itemSizeSmall : 0

        visible: clipboardLabel.visible

        icon.source: "image://theme/icon-m-close"

        onClicked: clipboard.clearClipboard()
    }

    Label {
        id: selectedFilesLabel

        anchors.top: clipboardLabel.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right

        color: Theme.secondaryColor

        visible: false

        text: ""
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        height: visible == true ? Theme.itemSizeSmall : 0
        width: parent.width
    }
    IconButton {
        anchors.top: selectedFilesLabel.top
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge

        width: selectedFilesLabel.visible == true ? Theme.itemSizeSmall : 0
        height: selectedFilesLabel.visible == true ? Theme.itemSizeSmall : 0

        visible: selectedFilesLabel.visible

        icon.source: "image://theme/icon-m-close"

        onClicked: {
            clipboard.clearSelectedFiles()
            getDirectoryPage().selectFiles(false)
        }
    }

    Grid {
        id: grid

        anchors.top: selectedFilesLabel.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        columns: item.width < Screen.height ? 3 : 6

        property int elementWidth: item.width < Screen.height ? item.width / 3 : item.width / 6
        property int elementHeight: Theme.itemSizeMedium

        ListItem {
            id: renameFiles
            width: visible == true ? grid.elementWidth : 0
            height: visible == true ? grid.elementHeight : 0
            visible: false
            Label {
                text: "Rename"
                anchors.centerIn: parent
            }

            onClicked: {
                getDirectoryPage().renameFiles()
                getDirectoryPage().selectFiles(false)
            }
        }
        ListItem {
            id: copyFiles
            width: visible == true ? grid.elementWidth : 0
            height: visible == true ? grid.elementHeight : 0
            visible: false
            Label {
                text: "Copy"
                anchors.centerIn: parent
            }

            onClicked: {
                clipboard.changeFileOperation("copy", settings.dirPath)
                getDirectoryPage().selectFiles(false)
            }
        }
        ListItem {
            id: pasteFiles
            width: visible == true ? grid.elementWidth : 0
            height: visible == true ? grid.elementHeight : 0
            visible: false
            Label {
                text: "Paste"
                anchors.centerIn: parent
            }

            onClicked: {
                getDirectoryPage().performFileOperation("paste")
            }
        }
        ListItem {
            id: deleteFiles
            width: visible == true ? grid.elementWidth : 0
            height: visible == true ? grid.elementHeight : 0
            visible: false
            Label {
                text: "Delete"
                anchors.centerIn: parent
            }

            onClicked: {
                getDirectoryPage().performFileOperation("delete")
            }
        }
    }

    Connections {
        target: clipboard
        onFileOperationChanged: updateView()
        onSelectedFileCountChanged: updateView()
        onClipboardFileCountChanged: updateView()
        onClipboardCleared: updateView()
        onClipboardDirChanged: updateView()
        onSelectedFilesCleared: updateView()
    }

    function updateView()
    {
        selectedFilesLabel.visible = false
        clipboardLabel.visible = false
        item.visible = false

        // 'visible' value for objects returns false even if they are set to true
        // during this function. Because of this, use these bools instead
        var selectedFilesLabelVisible = false
        var clipboardLabelVisible = false
        var visibleItems = 0

        // Update clipboard label
        if (clipboard.getClipboardFileCount() > 0)
        {
            visibleItems += 1
            pasteFiles.visible = true
            clipboardLabelVisible = true
            if (clipboard.getClipboardFileCount() == 1)
                clipboardLabel.text = "1 entry in clipboard"
            else
                clipboardLabel.text = clipboard.getClipboardFileCount() + " entries in clipboard"
        }
        else
        {
            pasteFiles.visible = false
        }

        // Update selected files label
        if (clipboard.getSelectedFileCount() > 0)
        {
            visibleItems += 2
            deleteFiles.visible = true
            renameFiles.visible = true
            selectedFilesLabelVisible = true
            if (clipboard.getSelectedFileCount() == 1)
                selectedFilesLabel.text = "1 entry selected"
            else
                selectedFilesLabel.text = clipboard.getSelectedFileCount() + " entries selected"
        }
        else
        {
            deleteFiles.visible = false
            renameFiles.visible = false
            selectedFilesLabel.visible = false
        }

        // Can copy files
        if (selectingItems == true && clipboard.getSelectedFileCount() > 0)
        {
            visibleItems += 1
            copyFiles.visible = true
        }
        else
        {
            copyFiles.visible = false
        }

        selectedFilesLabel.visible = selectedFilesLabelVisible
        clipboardLabel.visible = clipboardLabelVisible
        item.visible = visibleItems > 0 ? true : false

        if (visibleItems > 0)
            item.height = (clipboardLabelVisible == true ? Theme.itemSizeSmall : 0) +
                            (selectedFilesLabelVisible == true ? Theme.itemSizeSmall : 0) +
                            (Math.floor((visibleItems - 1) / 3) * grid.elementHeight) + grid.elementHeight
        else
            item.height = 0
    }
}
