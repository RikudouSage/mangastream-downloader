#include "headers/misctools.h"

bool MiscTools::openDirectory(QString directory) {
    directory = getFilePrefix()+directory;
    return QDesktopServices::openUrl(QUrl(directory));
}

bool MiscTools::isWindows() {
#if defined(Q_OS_WIN)
    return true;
#else
    return false;
#endif
}

QString MiscTools::getAppPath() {
    return QDir::currentPath();
}

QString MiscTools::getFilePrefix() {
    if(isWindows()) {
        return QString("file:///");
    }
    return QString("file://");
}
