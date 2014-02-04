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
                title: "File ordering"
            }

            Column {
                width: parent.width
                ComboBox {
                    width: parent.width
                    label: "Sort by"

                    menu: ContextMenu {
                        MenuItem { text: "Name" }
                        MenuItem { text: "Time" }
                        MenuItem { text: "Size" }
                        MenuItem { text: "Type" }
                    }

                    onCurrentIndexChanged: {
                        switch (currentIndex)
                        {
                            case 0:
                                settings.sortBy = "name"
                                break;

                            case 1:
                                settings.sortBy = "time"
                                break;

                            case 2:
                                settings.sortBy = "size"
                                break;

                            case 3:
                                settings.sortBy = "type"
                                break;
                        }
                    }

                    onParentChanged: {
                        switch (settings.sortBy)
                        {
                            case "name":
                                currentIndex = 0
                                break;

                            case "time":
                                currentIndex = 1
                                break;

                            case "size":
                                currentIndex = 2
                                break;

                            case "type":
                                currentIndex = 3
                                break;
                        }
                    }
                }
                ComboBox {
                    width: parent.width
                    label: "Sort order"

                    menu: ContextMenu {
                        MenuItem { text: "Ascending" }
                        MenuItem { text: "Descending" }
                    }

                    onCurrentIndexChanged: {
                        switch (currentIndex)
                        {
                            case 0:
                                settings.sortOrder = "asc"
                                break;

                            case 1:
                                settings.sortOrder = "desc"
                                break;
                        }
                    }

                    onParentChanged: {
                        switch (settings.sortOrder)
                        {
                            case "asc":
                                currentIndex = 0
                                break;

                            case "desc":
                                currentIndex = 1
                                break;
                        }
                    }
                }
                ComboBox {
                    width: parent.width
                    label: "Directory order"

                    menu: ContextMenu {
                        MenuItem { text: "Display directories first" }
                        MenuItem { text: "Display directories last" }
                        MenuItem { text: "Don't order directories" }
                    }

                    onCurrentIndexChanged: {
                        switch (currentIndex)
                        {
                            case 0:
                                settings.dirOrder = "first"
                                break;

                            case 1:
                                settings.dirOrder = "last"
                                break;

                            case 2:
                                settings.dirOrder = "none"
                                break;
                        }
                    }

                    onParentChanged: {
                        switch (settings.dirOrder)
                        {
                            case "first":
                                currentIndex = 0
                                break;

                            case "last":
                                currentIndex = 1
                                break;

                            case "none":
                                currentIndex = 2
                                break;
                        }
                    }
                }
            }

        }
    }
}
