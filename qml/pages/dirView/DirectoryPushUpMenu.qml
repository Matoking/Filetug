import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../js/directoryViewModel.js" as DirectoryViewModel

PushUpMenu {
    id: pushUpMenu

    MenuItem {
        text: "Scroll to top"
        onClicked: getDirectoryView().scrollToTop()
    }
    MenuItem {
        id: addToBookmarks
        text: "Add to bookmarks"
        onClicked: {
            visible = false
            removeFromBookmarks.visible = true
            settings.addBookmarkPath(settings.dirPath, settings.dirPath)
        }
        visible: !settings.isPathInBookmarks(settings.dirPath)
    }
    MenuItem {
        id: removeFromBookmarks
        text: "Remove from bookmarks"
        onClicked: {
            visible = false
            addToBookmarks.visible = true
            settings.removeBookmarkPath(settings.dirPath)
        }
        visible: settings.isPathInBookmarks(settings.dirPath)
    }
    MenuItem {
        text: "Shortcuts"
        onClicked: getDirectoryPage().openShortcuts()
    }
    MenuItem {
        id: directoryProperties
        visible: 'isShortcutsPage' in getDirectoryView() ? false : true
        text: "Directory properties"
        onClicked: {
            var fullPath = settings.dirPath
            var fileName = fullPath.substring(fullPath.lastIndexOf("/")+1, fullPath.length)
            var path = fullPath.replace(fileName, "")

            var entry = { "fullPath": fullPath,
                          "fileName": fileName,
                          "path": path,
                          "fileType": "dirinfo",
                          "thumbnail": "qrc:/icons/directory"  }

            DirectoryViewModel.openFile(entry)
        }
    }
}
