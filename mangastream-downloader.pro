system(lupdate mangastream-downloader.pro)
system(lrelease mangastream-downloader.pro)

QT += quick
CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += main.cpp \
    mangastream.cpp \
    misctools.cpp \
    imagedownloader.cpp

RESOURCES += qml.qrc \
            translations.qrc

lupdate_only {
    SOURCES += *.qml
}

TRANSLATIONS += translations/cs_CZ.ts

RC_ICONS = appicon.ico

QML_IMPORT_PATH =

QML_DESIGNER_IMPORT_PATH =

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    mangastream.h \
    misctools.h \
    imagedownloader.h

