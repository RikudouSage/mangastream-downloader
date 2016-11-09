#include "headers/misctools.h"
#include <QDebug>

bool MiscTools::openDirectory(QString directory) {
    directory = getFilePrefix()+directory;
    return QDesktopServices::openUrl(QUrl(directory));
}

QString MiscTools::getAppPath() {
    return QDir::currentPath();
}

QString MiscTools::getFilePrefix() {
#if defined(Q_OS_WIN)
    return QString("file:///");
#else
    return QString("file://");
#endif
}
