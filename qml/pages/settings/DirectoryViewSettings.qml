import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}
        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader {
                title: "Directory view"
            }

            SectionHeader {
                id: directoryLookHeader
                text: "Directory look"
            }
            Column {
                width: parent.width
                ComboBox {
                    width: parent.width
                    label: "Default view mode"
                    currentIndex: settings.defaultViewMode == "grid" ? 1 : 0

                    menu: ContextMenu {
                        MenuItem { text: "List" }
                        MenuItem { text: "Grid" }
                    }

                    onCurrentIndexChanged: {
                        if (currentIndex === 0)
                            settings.defaultViewMode = "list"
                        else if (currentIndex === 1)
                            settings.defaultViewMode = "grid"
                    }
                }
                TextSwitch {
                    text: "Show hidden files"
                    description: "Show hidden files and folders"

                    checked: settings.showHiddenFiles

                    onCheckedChanged: settings.showHiddenFiles = checked
                }
                TextSwitch {
                    text: "Show page header"
                    description: "Show page header with the current path"

                    checked: settings.showDirHeader

                    onCheckedChanged: settings.showDirHeader = checked
                }
                TextSwitch {
                    text: "Gallery mode"
                    description: "Use grid view when viewing a directory that contains images"

                    checked: settings.galleryMode

                    onCheckedChanged: settings.galleryMode = checked
                }
            }

            SectionHeader {
                text: "Thumbnails"
            }
            Column {
                // No spacing in this column
                width: parent.width
                TextSwitch {
                    text: "Display thumbnails"
                    description: "Display thumbnails for image files"

                    checked: settings.displayThumbnails

                    onCheckedChanged: settings.displayThumbnails = checked
                }
                TextSwitch {
                    text: "Cache thumbnails"
                    description: "Save generated thumbnails for faster loading"

                    checked: settings.cacheThumbnails

                    onCheckedChanged: settings.cacheThumbnails = checked
                }
            }
        }
    }
}
