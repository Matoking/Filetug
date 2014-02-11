import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    property string operation: ""
    property string path: ""

    property string currentFileType: "directory"

    property var files: [ ]

    canAccept: true

    allowedOrientations: Orientation.All

    onAccepted: {
        addEntries()
    }

    SilicaListView {
        id: listView

        contentHeight: childrenRect.height

        height: parent.height
        width: parent.width

        model: fileModel

        header: DialogHeader {
            id: dialogHeader
            acceptText: "Add"
        }

        ListModel {
            id: fileModel
        }

        delegate: Component {
            ListItem {
                contentHeight: column.height

                Column {
                    id: column

                    spacing: Theme.paddingSmall

                    Row {
                        x: Theme.paddingLarge

                        width: parent.width
                        height: Theme.itemSizeMedium

                        Label {
                            id: fileLabel
                            width: dialog.width - Theme.paddingLarge - Theme.itemSizeMedium
                            height: parent.height

                            verticalAlignment: Text.AlignVCenter

                            font.pixelSize: Theme.fontSizeSmall

                            color: Theme.secondaryColor

                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                            text: model.type
                        }
                        IconButton {
                            width: Theme.itemSizeMedium
                            height: Theme.itemSizeMedium

                            icon.source: "image://theme/icon-m-remove"

                            onClicked: removeEntry(index)
                        }
                    }

                    TextField {
                        id: textField

                        width: dialog.width - Theme.paddingLarge

                        // The file name is empty (aka invalid) by default
                        errorHighlight: true

                        text: model.name

                        onTextChanged: {
                            textField.errorHighlight = !validateEntryName(text)
                            updateEntryName(model.id, text)
                            validateEntryNames()
                        }
                    }
                }
            }
        }

        footer: BackgroundItem {
            id: backgroundItem

            property bool menuOpen: contextMenu != null && contextMenu.parent === backgroundItem

            y: listView.contentHeight

            width: parent.width
            height: menuOpen ? contextMenu.height + Theme.itemSizeLarge : Theme.itemSizeLarge

            onPressAndHold: contextMenu.show(backgroundItem)

            Row {
                id: row
                x: Theme.paddingLarge
                y: parent.y

                width: parent.width
                height: parent.height

                Label {
                    id: addNewLabel

                    width: paintedWidth
                    height: Theme.itemSizeLarge

                    verticalAlignment: Text.AlignVCenter

                    // TODO: Allow user to create files
                    text: "Add new "
                }
                Label {
                    width: paintedWidth
                    height: Theme.itemSizeLarge

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft

                    text: currentFileType

                    color: Theme.highlightColor
                }
            }

            IconButton {
                x: dialog.width - Theme.itemSizeMedium
                width: Theme.itemSizeMedium
                height: Theme.itemSizeMedium

                anchors.verticalCenter: backgroundItem.verticalCenter

                icon.source: "image://theme/icon-m-add"

                onClicked: addNewEntry()
            }

            ContextMenu {
                id: contextMenu

                MenuItem {
                    text: "directory"
                    onClicked: currentFileType = "directory"
                }
                MenuItem {
                    text: "file"
                    onClicked: currentFileType = "file"
                }
            }
        }
    }

    /*
     *  Add new entry to the model
     */
    function addNewEntry()
    {
        fileModel.append({ "id": fileModel.count,
                           "type": currentFileType,
                           "path": path,
                           "name": "" })

        canAccept = false
    }

    /*
     *  Remove an entry from the model
     */
    function removeEntry(index)
    {
        fileModel.remove(index)
    }

    /*
     *  Add files/directories defined in the model
     */
    function addEntries()
    {
        var entries = [];

        for (var i=0; i < fileModel.count; i++)
        {
            var entry = {};
            entry.path = fileModel.get(i).path
            entry.type = fileModel.get(i).type
            entry.name = fileModel.get(i).name

            entries[entries.length] = entry
        }

        // Convert the file array into JSON
        var json = JSON.stringify(entries)

        engine.createEntries(json)

        // Reload the directory view
        getDirectoryPage().refreshDirectoryView()
    }

    /*
     *  Validate all entry names
     */
    function validateEntryNames()
    {
        var invalidFileNames = 0
        for (var i=0; i < fileModel.count; i++)
        {
            var entryName = fileModel.get(i).name

            if (!validateEntryName(entryName))
                invalidFileNames += 1
        }

        if (invalidFileNames > 0)
            dialog.canAccept = false
        else
            dialog.canAccept = true
    }

    /*
     *  Check if the file name is valid
     */
    function validateEntryName(entryName)
    {
        if (entryName.indexOf("\\") != -1 || entryName.indexOf("/") != -1 || entryName == "")
            return false
        else
            return true
    }

    function updateEntryName(id, name)
    {
        fileModel.get(id).name = name
    }
}
