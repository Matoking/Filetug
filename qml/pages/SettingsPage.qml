import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage

    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: listModel

        header: PageHeader { title: "Settings" }

        delegate: ListItem {
            id: listItem
            onClicked: {
                pageStack.push(Qt.resolvedUrl(model.page))
            }
            Label {
                x: Theme.paddingLarge
                text: model.title
                anchors.verticalCenter: parent.verticalCenter
                font.capitalization: Font.Capitalize
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
        }

    }

    ListModel {
        id: listModel

        ListElement {
            title: "Directory view"
            page: "settings/DirectoryViewSettings.qml"
        }
        ListElement {
            title: "File ordering"
            page: "settings/FileOrderSettings.qml"
        }

        ListElement {
            title: "File display"
            page: "settings/FileDisplay.qml"
        }
    }
}
