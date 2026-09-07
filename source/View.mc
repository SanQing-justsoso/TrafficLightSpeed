// View.mc - 速度数据字段
// 大字实时速度 + 右上角小字平均速度
// 颜色：当前 > 平均 = 绿，< 平均 = 红，= 平均 = 白
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class EdgeRideFieldView extends WatchUi.SimpleDataField {

    private var _currentSpeed as Float?;
    private var _averageSpeed as Float?;
    private var _unit as String;
    private var _speedFactor as Float;

    function initialize() {
        SimpleDataField.initialize();
        label = "速度";

        var settings = System.getDeviceSettings();
        var isMetric = (settings.paceUnits == System.UNIT_METRIC);
        _unit = isMetric ? "km/h" : "mph";
        _speedFactor = isMetric ? 3.6 : 2.23694;
    }

    function compute(info) {
        _currentSpeed = info.currentSpeed;
        _averageSpeed = info.averageSpeed;
        return formatSpeed(_currentSpeed);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        var txtColor = Graphics.COLOR_WHITE;
        if (_currentSpeed != null && _averageSpeed != null && _averageSpeed > 0) {
            var diff = _currentSpeed - _averageSpeed;
            if (diff > _averageSpeed * 0.01) {
                txtColor = Graphics.COLOR_GREEN;
            } else if (diff < -_averageSpeed * 0.01) {
                txtColor = Graphics.COLOR_RED;
            }
        }

        var bigFont = Graphics.FONT_LARGE;
        if (h < 55) {
            bigFont = Graphics.FONT_MEDIUM;
        } else if (h >= 80) {
            bigFont = Graphics.FONT_NUMBER_HOT;
        }

        dc.setColor(txtColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h / 2 - 2, bigFont,
            formatSpeed(_currentSpeed),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w - 2, 2, Graphics.FONT_SMALL,
            formatSpeed(_averageSpeed) + " " + _unit,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function formatSpeed(speed) {
        if (speed == null) {
            return "--";
        }
        return (speed * _speedFactor).format("%.1f");
    }
}
