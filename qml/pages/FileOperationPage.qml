import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: fileOperationPage

    property string fileOperation: ""
    property string clipboardDir: ""

    property bool isFileOperationPage: true
    property bool fileOperationStarted: false

    property var clipboard: [ ]
    property var selectedFiles: [ ]
    property string directory: ""

    backNavigation: false

    allowedOrientations: Orientation.All

    PageHeader {
        id: pageHeader
        title: "Copying files"
    }

    Label {
        id: progressTextLabel

        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        text: ""

        horizontalAlignment: Text.AlignHCenter

        anchors.top: parent.top
        anchors.topMargin: Theme.itemSizeLarge + Theme.paddingLarge
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Label {
        id: currentEntryLabel

        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        text: ""

        horizontalAlignment: Text.AlignHCenter

        anchors.top: progressTextLabel.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.left: parent.left
        anchors.right: parent.right
    }

    ProgressBar {
        id: progressBar
        minimumValue: 0
        maximumValue: 1

        anchors.top: currentEntryLabel.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Connections {
        target: engine
        onFileOperationFinished: {
            progressBar.indeterminate = false
            progressBar.value = 1
            backNavigation = true
        }
        onCurrentEntryChanged: {
            currentEntryLabel.text = currentEntry
        }
        onProgressValueChanged: {
            if (progressValue == -1)
                progressBar.indeterminate = true
            else
            {
                progressBar.indeterminate = false
                progressBar.value = progressValue
            }
        }
        onProgressTextChanged: {
            progressTextLabel.text = progressText
        }
    }

    onStatusChanged: if (status == PageStatus.Active && !fileOperationStarted) performFileOperation()

    function performFileOperation()
    {
        fileOperationStarted = true

        switch (fileOperation)
        {
            case "paste":
                engine.performFileOperation("paste",
                                            clipboard,
                                            clipboardDir,
                                            selectedFiles,
                                            directory)
                pageHeader.title = "Copying files"
                break;

            case "delete":
                engine.performFileOperation("delete",
                                            clipboard,
                                            clipboardDir,
                                            selectedFiles,
                                            directory)
                pageHeader.title = "Deleting files"
                break;
        }
    }
}
