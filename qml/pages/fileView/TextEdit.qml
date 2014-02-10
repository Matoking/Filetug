import QtQuick 2.0
import Sailfish.Silica 1.0

Page  {
    id: page

    allowedOrientations: Orientation.All

    showNavigationIndicator: false

    // Current displayed file
    property var fileEntry: null

    RemorsePopup { id: remorsePopup }

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: textArea.height

        PullDownMenu {
            MenuItem {
                text: "Go back"
                onClicked: pageStack.pop()
            }
            MenuItem {
                text: "Clear"
                onClicked: remorsePopup.execute("Clearing text area", function() { textArea.text = "" })
            }
            MenuItem {
                text: "Save"
                onClicked: remorsePopup.execute("Saving file", function() { fileInfo.setFileContent(fileEntry.fullPath, textArea.text) })
            }
        }

        TextArea {
            id: textArea

            anchors.left: parent.left
            anchors.right: parent.right

            focus: true

            font.family: "monospace"
            font.pixelSize: Theme.fontSizeTiny

            text: fileInfo.getFileContent(fileEntry.fullPath)
        }
    }
}
