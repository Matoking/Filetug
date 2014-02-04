#include "covermodel.h"

CoverModel::CoverModel(QObject *parent) :
    QObject(parent)
{
    m_coverLabel = "";

    // Since the file manager always starts with a directory view visible,
    // the default icon is directory
    m_iconSource = "qrc:/icons/directory";
}

/*
 *  coverLabel - label shown on the cover
 */
void CoverModel::setCoverLabel(const QString &coverLabel)
{
    if (m_coverLabel != coverLabel)
    {
        m_coverLabel = coverLabel;
        emit coverLabelChanged(coverLabel);
    }
}

QString CoverModel::getCoverLabel() const
{
    return m_coverLabel;
}

/*
 *  iconSource - icon displayed on the cover
 */
void CoverModel::setIconSource(const QString &iconSource)
{
    if (m_iconSource != iconSource)
    {
        m_iconSource = iconSource;
        emit iconSourceChanged(iconSource);
    }
}

QString CoverModel::getIconSource() const
{
    return m_iconSource;
}
