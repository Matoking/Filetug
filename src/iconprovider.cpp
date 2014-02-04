#include "iconprovider.h"

QImage IconProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QImage image(id);

    if (!image.isNull())
    {
        for (int i=0; image.height()*image.width(); i++)
        {
        }
    }
    else
        qDebug() << "Aww sheet";

    // Return null image if all else fails
    return QImage();
}
