#include "settings.h"

Settings::Settings(QObject *parent) :
    QObject(parent)
{
    qDebug() << "Reading config";

    settings = new QSettings("Matoking", "MediaViewer");

    // Get stored values
    if (settings->contains("dirPath"))
        m_dirPath = settings->value("dirPath").toString();
    else
        m_dirPath = "/home/nemo"; // Default path

    if (settings->contains("defaultViewMode"))
        m_defaultViewMode = settings->value("defaultViewMode").toString();
    else
        m_defaultViewMode = "grid";

    if (settings->contains("showHiddenFiles"))
        m_showHiddenFiles = settings->value("showHiddenFiles").toBool();
    else
        m_showHiddenFiles = false;

    if (settings->contains("showDirHeader"))
        m_showDirHeader = settings->value("showDirHeader").toBool();
    else
        m_showDirHeader = true;

    if (settings->contains("galleryMode"))
        m_galleryMode = settings->value("galleryMode").toBool();
    else
        m_galleryMode = true;

    if (settings->contains("displayThumbnails"))
        m_displayThumbnails = settings->value("displayThumbnails").toBool();
    else
        m_displayThumbnails = true;

    if (settings->contains("cacheThumbnails"))
        m_cacheThumbnails = settings->value("cacheThumbnails").toBool();
    else
        m_cacheThumbnails = true;

    if (settings->contains("sortBy"))
        m_sortBy = settings->value("sortBy").toString();
    else
        m_sortBy = "name";

    if (settings->contains("sortOrder"))
        m_sortOrder = settings->value("sortOrder").toString();
    else
        m_sortOrder = "asc";

    if (settings->contains("dirOrder"))
        m_dirOrder = settings->value("dirOrder").toString();
    else
        m_dirOrder = "first";

    if (settings->contains("fileOverlayPeriod"))
        m_fileOverlayPeriod = settings->value("fileOverlayPeriod").toFloat();
    else
        m_fileOverlayPeriod = 2;

    if (settings->contains("browseAllFileTypes"))
        m_browseAllFileTypes = settings->value("browseAllFileTypes").toBool();
    else
        m_browseAllFileTypes = false;
}

/*
 *  dirPath - currently displayed directory
 */
void Settings::setDirPath(const QString &dirPath)
{
    if (m_dirPath != dirPath)
    {
        m_dirPath = dirPath;
        settings->setValue("dirPath", dirPath);
        settings->sync();
        emit dirPathChanged(dirPath);
    }
}

QString Settings::getDirPath() const
{
    return m_dirPath;
}

/*
 *  defaultViewMode - default view mode when viewing directories
 */
void Settings::setDefaultViewMode(const QString &defaultViewMode)
{
    if (m_defaultViewMode != defaultViewMode && (defaultViewMode == "grid" || defaultViewMode == "list"))
    {
        m_defaultViewMode = defaultViewMode;
        settings->setValue("defaultViewMode", defaultViewMode);
        settings->sync();
        emit defaultViewModeChanged(defaultViewMode);
        emit directoryViewSettingsChanged();
    }
}

QString Settings::getDefaultViewMode() const
{
    return m_defaultViewMode;
}

/*
 *  showHiddenFiles - show hidden files and folders
 */
void Settings::setShowHiddenFiles(const bool &showHiddenFiles)
{
    if (m_showHiddenFiles != showHiddenFiles)
    {
        m_showHiddenFiles = showHiddenFiles;
        settings->setValue("showHiddenFiles", QVariant(showHiddenFiles));
        settings->sync();
        emit showHiddenFilesChanged(showHiddenFiles);
        emit directoryViewSettingsChanged();
    }
}

bool Settings::getShowHiddenFiles() const
{
    return m_showHiddenFiles;
}

/*
 *  showDirHeader - show the page header in directory view
 */
void Settings::setShowDirHeader(const bool &showDirHeader)
{
    if (m_showDirHeader != showDirHeader)
    {
        m_showDirHeader = showDirHeader;
        settings->setValue("showDirHeader", QVariant(showDirHeader));
        settings->sync();
        emit showDirHeaderChanged(showDirHeader);
        emit directoryViewSettingsChanged();
    }
}

bool Settings::getShowDirHeader() const
{
    return m_showDirHeader;
}

/*
 *  galleryMode - use grid view automatically when viewing a directory containing image and/or video files
 */
void Settings::setGalleryMode(const bool &galleryMode)
{
    if (m_galleryMode != galleryMode)
    {
        m_galleryMode = galleryMode;
        settings->setValue("galleryMode", QVariant(galleryMode));
        settings->sync();
        emit galleryModeChanged(galleryMode);
        emit directoryViewSettingsChanged();
    }
}

bool Settings::getGalleryMode() const
{
    return m_galleryMode;
}

/*
 *  displayThumbnails - display thumbnails for image and video files
 */
void Settings::setDisplayThumbnails(const bool &displayThumbnails)
{
    if (m_displayThumbnails != displayThumbnails)
    {
        m_displayThumbnails = displayThumbnails;
        settings->setValue("displayThumbnails", QVariant(displayThumbnails));
        settings->sync();
        emit displayThumbnailsChanged(displayThumbnails);
    }
}

bool Settings::getDisplayThumbnails() const
{
    return m_displayThumbnails;
}

/*
 *  cacheThumbnails - save generated thumbnails for faster loading
 */
void Settings::setCacheThumbnails(const bool &cacheThumbnails)
{
    if (m_cacheThumbnails != cacheThumbnails)
    {
        m_cacheThumbnails = cacheThumbnails;
        settings->setValue("cacheThumbnails", QVariant(cacheThumbnails));
        settings->sync();
        emit cacheThumbnailsChanged(cacheThumbnails);
    }
}

bool Settings::getCacheThumbnails() const
{
    return m_cacheThumbnails;
}

/*
 *  sortBy - sort files by name, type, size or time
 */
void Settings::setSortBy(const QString &sortBy)
{
    if (m_sortBy != sortBy)
    {
        m_sortBy = sortBy;
        settings->setValue("sortBy", QVariant(sortBy));
        settings->sync();
        emit sortByChanged(sortBy);
        emit directoryViewSettingsChanged();
    }
}

QString Settings::getSortBy() const
{
    return m_sortBy;
}

/*
 *  sortOrder - sort files either in an ascending or descending order
 */
void Settings::setSortOrder(const QString &sortOrder)
{
    if (m_sortOrder != sortOrder)
    {
        m_sortOrder = sortOrder;
        settings->setValue("sortOrder", QVariant(sortOrder));
        settings->sync();
        emit sortOrderChanged(sortOrder);
        emit directoryViewSettingsChanged();
    }
}

QString Settings::getSortOrder() const
{
    return m_sortOrder;
}

/*
 *  dirOrder - show directories either first or last or don't order them at all
 */
void Settings::setDirOrder(const QString &dirOrder)
{
    if (m_dirOrder != dirOrder)
    {
        m_dirOrder = dirOrder;
        settings->setValue("dirOrder", QVariant(dirOrder));
        settings->sync();
        emit dirOrderChanged(dirOrder);
        emit directoryViewSettingsChanged();
    }
}

QString Settings::getDirOrder() const
{
    return m_dirOrder;
}

/*
 *  fileOverlayPeriod - how long the file overlay will stay visible after it has been invoked
 */
void Settings::setFileOverlayPeriod(const float &fileOverlayPeriod)
{
    if (m_fileOverlayPeriod != fileOverlayPeriod)
    {
        m_fileOverlayPeriod = fileOverlayPeriod;
        settings->setValue("fileOverlayPeriod", QVariant(fileOverlayPeriod));
        settings->sync();
        emit fileOverlayPeriodChanged(fileOverlayPeriod);
        emit fileDisplaySettingsChanged();
    }
}

float Settings::getFileOverlayPeriod() const
{
    return m_fileOverlayPeriod;
}

/*
 *  browseAllFileTypes - whether the file browser goes through all types of displayable
 *  files as opposed to files of the same type
 */
void Settings::setBrowseAllFileTypes(const bool &browseAllFileTypes)
{
    if (m_browseAllFileTypes != browseAllFileTypes)
    {
        m_browseAllFileTypes = browseAllFileTypes;
        settings->setValue("browseAllFileTypes", QVariant(browseAllFileTypes));
        settings->sync();
        emit browseAllFileTypesChanged(browseAllFileTypes);
        emit fileDisplaySettingsChanged();
    }
}

bool Settings::getBrowseAllFileTypes() const
{
    return m_browseAllFileTypes;
}
