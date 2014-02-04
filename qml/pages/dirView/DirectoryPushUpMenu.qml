import QtQuick 2.0
import Sailfish.Silica 1.0

PushUpMenu {
    id: pushUpMenu

    MenuItem {
        text: "Scroll to top"
        onClicked: getDirectoryView().scrollToTop()
    }
}
