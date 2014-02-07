import QtQuick 2.0
import Sailfish.Silica 1.0

// A placeholder page that is shown while the actual directory view is loaded
Page {
    id: page

    onStatusChanged: {
        if (status == PageStatus.Active) pageStack.push(Qt.resolvedUrl("DirectoryPage.qml"), null, PageStackAction.Immediate)
    }

    // Directory title header
    SilicaListView {
        anchors.fill: parent

        PullDownMenu { }

        header: Item {
            anchors.left: parent.left
            anchors.right: parent.right

            height: Theme.itemSizeLarge

            Label {
                id: headerLabel

                text: settings.dirPath

                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge

                color: Theme.highlightColor

                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter

                height: settings.showDirHeader == true ? Theme.itemSizeLarge : 0

                visible: settings.showDirHeader
            }
            OpacityRampEffect {
                direction: OpacityRamp.RightToLeft
                slope: 4
                offset: 0.75
                sourceItem: headerLabel
            }
        }
    }
}
