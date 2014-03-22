import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../js/misc.js" as Misc
import "../../js/directoryViewModel.js" as DirectoryViewModel

Page {
    id: page

    property var fileEntry: null

    property string fileFormat: "..."

    // Process related vars
    property string progressText: ""
    property double progress: 0
    property bool progressIndeterminate: false
    property bool actionRunning: false

    property bool progressBarVisible: false
    property bool actionLabelVisible: false

    signal fileLoaded()

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent

        SilicaListView {
            id: listView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            width: parent.width
            height: parent.height

            model: listModel

            header: Item {
                        width: parent.width
                        height: childrenRect.height

                        PageHeader {
                            id: pageHeader
                            title: "File information"
                        }

                        ProgressBar {
                            id: progressBar
                            indeterminate: progressIndeterminate
                            value: progress

                            anchors.top: pageHeader.bottom

                            minimumValue: 0
                            maximumValue: 1

                            visible: progressBarVisible

                            label: progressText

                            width: parent.width
                        }
                        Text {
                            id: actionLabel

                            anchors.top: pageHeader.bottom
                            anchors.topMargin: progressBar.height / 2

                            text: progressText

                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.secondaryColor

                            horizontalAlignment: Text.AlignHCenter

                            visible: actionLabelVisible

                            width: parent.width
                        }

                        Image {
                            id: fileImage

                            anchors.top: progressBarVisible == true || actionLabelVisible == true ? progressBar.bottom : pageHeader.bottom
                            anchors.topMargin: Theme.paddingMedium
                            anchors.left: parent.left
                            anchors.right: parent.right

                            anchors.horizontalCenter: parent

                            fillMode: Image.PreserveAspectFit

                            height: Screen.height / 4

                            sourceSize.width: width
                            sourceSize.height: width

                            Component.onCompleted: {
                                if ('thumbnail' in fileEntry)
                                    source = fileEntry.thumbnail
                                else if (fileEntry.fileType == "image")
                                    source = fileEntry.fullPath
                                else
                                    source = "qrc:/icons/" + fileEntry.fileType
                            }
                        }

                        Label {
                            id: fileNameLabel

                            anchors.top: fileImage.bottom

                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap

                            width: parent.width

                            text: fileEntry.fileName
                        }
                        Label {
                            id: fileFormatLabel

                            anchors.top: fileNameLabel.bottom

                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            color: Theme.secondaryColor

                            width: parent.width

                            text: fileFormat
                        }

                }

            PullDownMenu {
                id: pullDownMenu

                visible: false

                Repeater {
                    model: pullDownModel
                    MenuItem {
                        text: model.label
                        onClicked: performFileAction(model.action, model.track, model.process)
                    }
                }
            }

            ListModel {
                id: pullDownModel
            }

            ListModel {
                id: listModel
            }

            VerticalScrollDecorator {}

            section {
                property: 'section'

                delegate: SectionHeader {
                    text: section
                    height: Theme.itemSizeExtraSmall
                }
            }

            /*Column {
                id: column
                spacing: Theme.paddingLarge
                width: parent.width
                PageHeader {
                    title: "File information"
                }

                Column {
                    width: parent.width

                    Label {
                        width: parent.width

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge

                        horizontalAlignment: Text.AlignHCenter

                        text: fileEntry.fileName
                    }

                    Label {
                        width: parent.width

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge

                        horizontalAlignment: Text.AlignHCenter

                        color: Theme.secondaryColor

                        text: "File type here bitch"
                    }
                }
            }*/

            delegate: Item {
                width: parent.width
                height: detailValueLabel.paintedHeight + Theme.paddingSmall

                Text {
                    id: detailLabel
                    width: (parent.width / 2) - Theme.paddingMedium

                    horizontalAlignment: Text.AlignRight

                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall

                    text: model.detailTitle
                }

                Text {
                    id: detailValueLabel
                    x: (parent.width / 2) + Theme.paddingMedium
                    width: (parent.width / 2) - Theme.paddingMedium

                    horizontalAlignment: Text.AlignLeft

                    wrapMode: Text.Wrap

                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall

                    text: model.detailValue
                }
            }

            footer: PermissionEdit {
                id: permissionEdit

                Component.onCompleted: permissionEdit.fullPath = fileEntry.fullPath
            }
        }
    }

    Connections {
        target: fileProcess
        onProgressChanged: updateActionDisplay()
        onFileChanged: updateActionDisplay()
        onProgressTextChanged: updateActionDisplay()
        onActionRunningChanged: updateActionDisplay()
    }

    onFileEntryChanged: {
        loadFile()
    }

    /*
     *  Load data for a file
     */
    function loadFile()
    {
        var fileData = fileInfo.getFileInfo(fileEntry.fullPath)
        var fileDetails = fileData.details

        fileFormat = fileData.fileFormat

        console.log(JSON.stringify(fileData))

        listModel.clear()

        // Add details
        for (var detailSection in fileData.details)
        {
            for (var detail in fileData.details[detailSection])
            {
                listModel.append( { "detailTitle": detail,
                                    "detailValue": fileData.details[detailSection][detail].toString(),
                                    "section": detailSection } )
            }
        }

        for (var action in fileData.actions)
        {
            var actionEntry = fileData.actions[action]

            pullDownMenu.visible = true

            // Add actions
            pullDownModel.append( { "label": actionEntry.label,
                                    "action": actionEntry.action,
                                    "track": 'track' in actionEntry ? actionEntry.track : true,
                                    "process": 'process' in actionEntry ? actionEntry.process : true } )
        }

        fileLoaded()
    }

    /*
     *  Update action display
     */
    function updateActionDisplay()
    {
        progress = fileProcess.actionProgress

        if (progress == -1)
            progressIndeterminate = true
        else
            progressIndeterminate = false

        progressText = fileProcess.progressText

        if (fileEntry.fullPath == fileProcess.file)
        {
            if (fileProcess.actionRunning)
            {
                progressBarVisible = true
                actionLabelVisible = false
            }
            else
            {
                progressBarVisible = false
                actionLabelVisible = true
            }
        }
        else
        {
            progressBarVisible = false
            actionLabelVisible = false
        }
    }

    /*
     *  Perform file action
     */
    function performFileAction(action, track, process)
    {
        console.log("Performing file action")

        // Perform the action
        if (process == true)
        {
            console.log("Performed")
            var result = fileProcess.performFileAction(fileEntry.fullPath, action, track)
        }
        else
        {
            // Perform an action that doesn't involve a process
            switch (action)
            {
                case 'showAsText':
                    var newFileEntry = { "fileName": fileEntry.fileName,
                                         "fullPath": fileEntry.fullPath,
                                         "fileType": "text",
                                         "path": fileEntry.path }
                    DirectoryViewModel.openFile(newFileEntry, "text")
                    break;

                case 'editAsText':
                    pageStack.push(Qt.resolvedUrl("TextEdit.qml"), { "fileEntry": fileEntry })
                    break;
            }
        }
    }
}
