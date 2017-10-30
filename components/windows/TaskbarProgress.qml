import QtQuick 2.5
import QtWinExtras 1.0

TaskbarButton {
    property int current
    property int maximum
    property bool progressVisible
    id: root
    onCurrentChanged: {
        root.progress.value = current;
    }
    onMaximumChanged: {
        root.progress.maximum = maximum;
    }
    onProgressVisibleChanged: {
        root.progress.visible = progressVisible;
    }
}
