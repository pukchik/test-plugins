import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Services.System
import qs.Widgets

Rectangle {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  readonly property string barPosition: Settings.data.bar.position || "top"
  readonly property bool barIsVertical: barPosition === "left" || barPosition === "right"

  implicitWidth: barIsVertical ? Style.barHeight : contentRow.implicitWidth + Style.marginL * 2
  implicitHeight: Style.barHeight

  color: Style.capsuleColor
  radius: Style.radiusM

  RowLayout {
    id: contentRow
    anchors.centerIn: parent
    spacing: Style.marginS

    NIcon {
      icon: "image"
      applyUiScale: false
      color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
    }

    NText {
      visible: !barIsVertical
      text: {
        const current = Settings.data.wallpaper.directory || "";
        if (!current) return "Wallpapers";
        const parts = current.split("/");
        return parts[parts.length - 1] || "Wallpapers";
      }
      color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
      pointSize: Style.barFontSize
      font.weight: Font.Medium
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    
    onEntered: {
      root.color = Color.mHover;
    }

    onExited: {
      root.color = Style.capsuleColor;
    }


    onClicked: mouse => {
      if (mouse.button === Qt.RightButton) {
        var popupMenuWindow = PanelService.getPopupMenuWindow(root.screen);
        if (popupMenuWindow) {
          popupMenuWindow.showContextMenu(contextMenu);
          contextMenu.openAtItem(root, root.screen);
        }
      } else if (pluginApi) {
        pluginApi.openPanel(root.screen, this);
      }
    }
  }

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": I18n.tr("actions.widget-settings"),
        "action": "widget-settings",
        "icon": "settings"
      }
    ]

    onTriggered: action => {
      var popupMenuWindow = PanelService.getPopupMenuWindow(root.screen);
      if (popupMenuWindow) {
        popupMenuWindow.close();
      }

      if (action === "widget-settings") {
        BarService.openPluginSettings(root.screen, pluginApi.manifest);
      }
    }
  }
}
