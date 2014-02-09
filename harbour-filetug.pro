# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-filetug

CONFIG += sailfishapp

QT += multimedia

SOURCES += \
    src/thumbnailprovider.cpp \
    src/settings.cpp \
    src/filelist.cpp \
    src/iconprovider.cpp \
    src/fileengine.cpp \
    src/fileinfoentry.cpp \
    src/fileinfo.cpp \
    src/fileprocess.cpp \
    src/worker.cpp \
    src/clipboard.cpp \
    src/main.cpp \
    src/covermodel.cpp \
    src/util.cpp

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    rpm/harbour-filetug.yaml \
    harbour-filetug.desktop \
    qml/pages/SettingsPage.qml \
    qml/pages/ImageView.qml \
    qml/pages/dirView/DirectoryGridView.qml \
    qml/js/directoryViewModel.js \
    qml/pages/dirView/DirectoryPullDownMenu.qml \
    qml/pages/dirView/DirectoryPushUpMenu.qml \
    qml/pages/settings/DirectoryViewSettings.qml \
    qml/pages/dirView/DirectoryListView.qml \
    qml/js/misc.js \
    qml/pages/settings/FileOrderSettings.qml \
    qml/pages/AboutPage.qml \
    qml/pages/fileView/FileInfo.qml \
    qml/js/imageView.js \
    qml/pages/fileView/AnimatedImageView.qml \
    qml/pages/fileView/Image.qml \
    qml/pages/fileView/Video.qml \
    qml/pages/fileView/Text.qml \
    qml/pages/FileOperationPage.qml \
    qml/pages/fileView/Audio.qml \
    qml/pages/FilePage.qml \
    qml/pages/FileRenameDialog.qml \
    qml/pages/NewFilesDialog.qml \
    qml/pages/settings/FileDisplay.qml \
    qml/Filetug.qml \
    qml/pages/DirectoryPage.qml \
    qml/pages/BackPage.qml \
    qml/pages/dirView/DirectoryFileOperations.qml \
    qml/pages/fileView/PermissionEdit.qml

HEADERS += \
    src/thumbnailprovider.h \
    src/settings.h \
    src/filelist.h \
    src/iconprovider.h \
    src/fileengine.h \
    src/fileinfoentry.h \
    src/fileinfo.h \
    src/fileprocess.h \
    src/worker.h \
    src/clipboard.h \
    src/covermodel.h \
    src/util.h

RESOURCES += \
    resources.qrc

