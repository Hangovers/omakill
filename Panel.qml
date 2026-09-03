import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.hangovers.omakill"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property string binDir: ""

  function open() {
    root.controller.show()
  }

  function close() {
    root.controller.hide()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.hostWidget || root, direction)
    return false
  }

  function activate(action) {
    if (root.hostWidget && typeof root.hostWidget.runAction === "function")
      root.hostWidget.runAction(action)
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(260))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(4)

        WidgetButton {
          width: parent.width
          height: Style.space(32)
          bar: root.bar
          text: "󰍉  By clicking"
          tooltipText: "Click any window to force-close it"
          onPressed: function(buttonCode) {
            if (buttonCode === Qt.LeftButton) root.activate("click")
          }
        }

        WidgetButton {
          width: parent.width
          height: Style.space(32)
          bar: root.bar
          text: "󰀻  Window"
          tooltipText: "Pick an open window to close"
          onPressed: function(buttonCode) {
            if (buttonCode === Qt.LeftButton) root.activate("window")
          }
        }

        WidgetButton {
          width: parent.width
          height: Style.space(32)
          bar: root.bar
          text: "󰋊  Process"
          tooltipText: "Pick a process to terminate (live CPU/MEM)"
          onPressed: function(buttonCode) {
            if (buttonCode === Qt.LeftButton) root.activate("process")
          }
        }

        WidgetButton {
          width: parent.width
          height: Style.space(32)
          bar: root.bar
          text: "󰨇  Task manager (btop)"
          tooltipText: "Monitor processes and resource usage"
          onPressed: function(buttonCode) {
            if (buttonCode === Qt.LeftButton) root.activate("tasks")
          }
        }
      }
    }
  }
}
