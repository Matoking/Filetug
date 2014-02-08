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

    function updateView()
    {
        updateItemVisibility()
    }

    function updateItemVisibility()
    {
        if (!selectingItems)
        {
            selectFilesItem.visible = true
            stopSelectingFilesItem.visible = false
        }
        else
        {
            stopSelectingFilesItem.visible = true
            selectFilesItem.visible = false
        }
    }

}
