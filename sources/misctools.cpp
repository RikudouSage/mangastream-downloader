#include "headers/misctools.h"

bool MiscTools::openDirectory(QString directory) {
    directory = "file://"+directory;
    return QDesktopServices::openUrl(QUrl(directory));
}
