#ifndef THUMBNAILPROVIDER_H
#define THUMBNAILPROVIDER_H

#include <QQuickImageProvider>
#include <QDebug>
#include <QImage>
#include <QFileInfo>
#include <QSize>
#include <QDir>

class ThumbnailProvider : public QQuickImageProvider
{
public:
    ThumbnailProvider() : QQuickImageProvider(QQuickImageProvider::Image) { }

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // THUMBNAILPROVIDER_H
