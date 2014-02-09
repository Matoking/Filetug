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
        text: "Scroll to bottom"
        onClicked: getDirectoryView().scrollToBottom()
    }

}
