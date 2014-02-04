#ifndef ICONPROVIDER_H
#define ICONPROVIDER_H

#include <QQuickImageProvider>
#include <QDebug>
#include <QImage>
#include <QFileInfo>
#include <QSize>
#include <QDir>
#include <QRgb>

class IconProvider : public QQuickImageProvider
{
public:
    IconProvider() : QQuickImageProvider(QQuickImageProvider::Image) { }

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // ICONPROVIDER_H
