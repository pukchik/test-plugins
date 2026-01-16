import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  readonly property var geometryPlaceholder: panelContainer

  property real contentPreferredWidth: 250 * Style.uiScaleRatio
  property real contentPreferredHeight: 300 * Style.uiScaleRatio

  readonly property bool allowAttach: true
  anchors.fill: parent

  readonly property var folders: pluginApi?.pluginSettings?.folders || []
  readonly property string currentFolder: Settings.data.wallpaper.directory || ""

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      anchors {
        fill: parent
        margins: Style.marginL
      }
      spacing: Style.marginM

      NText {
        text: "Wallpaper Folders"
        font.pointSize: Style.fontSizeL * Style.uiScaleRatio
        font.weight: Font.Medium
        color: Color.mOnSurface
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Color.mSurfaceVariant
        radius: Style.radiusM

        ListView {
          id: folderList
          anchors {
            fill: parent
            margins: Style.marginS
          }
          clip: true
          spacing: Style.marginS
          model: root.folders

          delegate: Rectangle {
            width: folderList.width
            height: 42 * Style.uiScaleRatio
            radius: Style.radiusS
            color: modelData === root.currentFolder ? Color.mTertiary : "transparent"

            RowLayout {
              anchors {
                fill: parent
                leftMargin: Style.marginM
                rightMargin: Style.marginM
              }
              spacing: Style.marginS

              NIcon {
                icon: "folder"
                color: modelData === root.currentFolder ? Color.mOnTertiary : Color.mOnSurfaceVariant
              }

              NText {
                Layout.fillWidth: true
                text: {
                  const parts = modelData.split("/");
                  return parts[parts.length - 1] || modelData;
                }
                color: modelData === root.currentFolder ? Color.mOnTertiary : Color.mOnSurfaceVariant
                elide: Text.ElideMiddle
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.selectFolder(modelData)
                }
            }
          }
        }

        NText {
          anchors.centerIn: parent
          visible: root.folders.length === 0
          text: "No folders configured.\nAdd folders in settings."
          color: Color.mOnSurfaceVariant
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }

  function selectFolder(folderPath) {
    Settings.data.wallpaper.directory = folderPath;
    Logger.i("WallpaperSwitcher", "Changed wallpaper directory to: " + folderPath);
    ToastService.showNotice("Folder: " + folderPath.split("/").pop());
    
    // Сохранить в плагин-апи
    if (root.pluginApi) {
      root.pluginApi.saveSettings();
    }
  }
}
