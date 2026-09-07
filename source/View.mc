// View.mc - 速度数据字段
// 未定位：背景三段红绿灯（上绿、中黄、下红）
// 定位后：整个格子背景根据实时速度 vs 平均速度变化
//   > 平均 3% = 全绿，< -3% = 全红，±3% 内 = 全黄
// 数值/字体统一深色字
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class EdgeRideFieldView extends WatchUi.DataField {

    private var _currentSpeed as Float?;
    private var _averageSpeed as Float?;
    private var _unit as String;
    private var _speedFactor as Float;

    function initialize() {
        DataField.initialize();

        var settings = System.getDeviceSettings();
        var isMetric = (settings.paceUnits == System.UNIT_METRIC);
        _unit = isMetric ? "km/h" : "mph";
        _speedFactor = isMetric ? 3.6 : 2.23694;
    }

    function onTimerLap() as Void {
    }

    function onTimerReset() as Void {
    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        _currentSpeed = info.currentSpeed;
        _averageSpeed = info.averageSpeed;
        return null;
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        var darkColor = Graphics.COLOR_BLACK;
        var grayColor = Graphics.COLOR_DK_GRAY;

        if (_currentSpeed == null || _averageSpeed == null || _averageSpeed <= 0) {
            // 未定位：三段红绿灯（上绿、中黄、下红）
            var topH = h / 3;
            var midH = (h * 2) / 3;

            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_GREEN);
            dc.fillRectangle(0, 0, w, topH);

            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);
            dc.fillRectangle(0, topH, w, midH - topH);

            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
            dc.fillRectangle(0, midH, w, h - midH);
        } else {
            // 定位后：整格单一背景，随速度变化
            var diff = _currentSpeed - _averageSpeed;
            var threshold = _averageSpeed * 0.03;
            var bgColor;
            if (diff > threshold) {
                bgColor = Graphics.COLOR_GREEN;
            } else if (diff < -threshold) {
                bgColor = Graphics.COLOR_RED;
            } else {
                bgColor = Graphics.COLOR_YELLOW;
            }
            dc.setColor(bgColor, bgColor);
            dc.clear();
        }

        // 标题（顶部）
        dc.setColor(darkColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, 8, Graphics.FONT_XTINY,
            "Speed / Avg",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 字号
        var bigFont = Graphics.FONT_LARGE;
        var unitFont = Graphics.FONT_SMALL;
        if (h < 55) {
            bigFont = Graphics.FONT_MEDIUM;
            unitFont = Graphics.FONT_XTINY;
        } else if (h >= 80) {
            bigFont = Graphics.FONT_NUMBER_HOT;
            unitFont = Graphics.FONT_SMALL;
        }

        // 大字区域：数值（大字）+ 单位（小字）
        var speedText = formatSpeed(_currentSpeed);
        if (_currentSpeed == null) {
            // 没定位：小号 "--"，不带单位，下移
            dc.setColor(darkColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2 + 2, unitFont,
                "--",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            // 数值大字（居中偏上）+ 单位小字（居中偏下）
            dc.setColor(darkColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2 - 6, bigFont,
                speedText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            dc.setColor(grayColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2 + 6, unitFont,
                _unit,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // 右上角平均速度（无单位，y=18）
        dc.setColor(darkColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w - 2, 18, Graphics.FONT_SMALL,
            formatSpeed(_averageSpeed),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function formatSpeed(speed) {
        if (speed == null) {
            return "--";
        }
        return (speed * _speedFactor).format("%.1f");
    }
}