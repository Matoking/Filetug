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
        text: "New..."
        visible: 'isShortcutsPage' in getDirectoryView() ? false : true
        onClicked: getDirectoryPage().addNewFiles()
    }
    MenuItem {
        text: "Scroll to bottom"
        onClicked: getDirectoryView().scrollToBottom()
    }

}
