import QtQuick 2.0
import Sailfish.Silica 1.0

PullDownMenu {
    id: pullDownMenu

    MenuItem {
        text: "About"
        onClicked: pageStack.push(Qt.resolvedUrl("../AboutPage.qml"))
    }
    MenuItem {
        text: "Settings"
        onClicked: pageStack.push(Qt.resolvedUrl("../SettingsPage.qml"))
    }
    MenuItem {
        text: "Go to home"
        onClicked: getDirectoryPage().openDirectory("/home/nemo", "left")
    }
    MenuItem {
        text: "New..."
        onClicked: getDirectoryPage().addNewFiles()
    }
    MenuItem {
        id: selectFilesItem
        text: "Select files"
        onClicked: {
            stopSelectingFilesItem.visible = true
            visible = false
            getDirectoryPage().selectFiles(true)
        }
    }
    MenuItem {
        id: stopSelectingFilesItem
        text: "Stop selecting files"
        visible: false
        onClicked: stopSelectingItems()

        function stopSelectingItems()
        {
            selectFilesItem.visible = true
            visible = false
            getDirectoryPage().selectFiles(false)
        }
    }

    MenuItem {
        text: "Scroll to bottom"
        onClicked: getDirectoryView().scrollToBottom()
    }

    MenuLabel {
        id: fileOperationLabel
        text: "<b>File operations</b>"
        visible: false

        Connections {
            target: clipboard
            onFileOperationChanged: pullDownMenu.updateItemVisibility()
            onClipboardFileCountChanged: pullDownMenu.updateItemVisibility()
            onSelectedFileCountChanged: pullDownMenu.updateItemVisibility()
            onSelectedFilesCleared: pullDownMenu.updateItemVisibility()
            onClipboardCleared: pullDownMenu.updateItemVisibility()
            onClipboardDirChanged: pullDownMenu.updateItemVisibility()
        }
    }

    MenuLabel {
        id: clipboardCountLabel
        text: ""
        visible: false
    }

    MenuItem {
        id: clearClipboard
        text: "Clear clipboard"
        visible: false
        onClicked: {
            clipboard.clearClipboard()
            stopSelectingFilesItem.stopSelectingItems()
        }
    }

    MenuItem {
        id: renameFiles
        text: "Rename"
        visible: false
        onClicked: {
            getDirectoryPage().renameFiles()
            stopSelectingFilesItem.stopSelectingItems()
        }
    }
    MenuItem {
        id: copyFiles
        text: "Copy"
        visible: false
        onClicked: {
            clipboard.changeFileOperation("copy", settings.dirPath)
            stopSelectingFilesItem.stopSelectingItems()
        }
    }
    MenuItem {
        id: pasteFiles
        text: "Paste"
        visible: false
        onClicked: {
            getDirectoryPage().performFileOperation("paste")
        }
    }
    MenuItem {
        id: deleteFiles
        text: "Delete"
        visible: false
        onClicked: {
            getDirectoryPage().performFileOperation("delete")
        }
    }

    function updateView()
    {
        updateItemVisibility()
    }

    function updateItemVisibility()
    {
        console.log("Come on and slam")

        fileOperationLabel.visible = false

        var visibleItems = false

        if (clipboard.getClipboardFileCount() > 0 && clipboard.fileOperation != "")
        {
            visibleItems = true
            clearClipboard.visible = true
        }
        else
        {
            clearClipboard.visible = false
        }

        if (selectingItems == true && clipboard.getSelectedFileCount() > 0)
        {
            visibleItems = true
            copyFiles.visible = true
        }
        else
        {
            copyFiles.visible = false
        }

        if (clipboard.getClipboardFileCount() > 0)
        {
            visibleItems = true
            pasteFiles.visible = true
        }
        else
        {
            pasteFiles.visible = false
        }

        if (clipboard.getSelectedFileCount() > 0)
        {
            visibleItems = true
            deleteFiles.visible = true
            renameFiles.visible = true
            selectFilesItem.visible = false
            stopSelectingFilesItem.visible = true
        }
        else
        {
            deleteFiles.visible = false
            renameFiles.visible = false
        }

        fileOperationLabel.visible = visibleItems

        if (visibleItems && clipboard.getClipboardFileCount() > 0)
        {
            clipboardCountLabel.text = clipboard.getClipboardFileCount() + " file(s) in clipboard"
            clipboardCountLabel.visible = true
        }
    }

}
