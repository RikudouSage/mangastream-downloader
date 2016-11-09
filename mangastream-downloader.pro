system(lupdate mangastream-downloader.pro)
system(lrelease mangastream-downloader.pro)

#DEFINES += DEBUG

TEMPLATE = app

QT += qml quick widgets

CONFIG += c++11

SOURCES += sources/main.cpp \
    sources/qdownloader.cpp \
    sources/mangastream.cpp \
    sources/misctools.cpp

RESOURCES += qml.qrc \
    translations.qrc

TRANSLATIONS += translations/cs_CZ.ts
TRANSLATIONS += translations/sk_SK.ts

QML_IMPORT_PATH =

include(deployment.pri)

HEADERS += \
    headers/qdownloader.h \
    headers/mangastream.h \
    headers/misctools.h \
    headers/isdebug.h

lupdate_only {
    SOURCES += qml/*.qml
}
