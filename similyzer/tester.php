<?php
// Project: similyzer
// File: tester.php 
// Created by Guy@GSR (11/12/2014)

function getCss()
{
    $rand = array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f');
    $color = '#' . $rand[rand(0, 15)] . $rand[rand(0, 15)] . $rand[rand(0, 15)] . $rand[rand(0, 15)] . $rand[rand(0, 15)] . $rand[rand(0, 15)];

// text color
    $color = str_replace('#', '', $color);
    if (strlen($color) != 6) {
        return '000000';
    }
    $rgb = '';
    for ($x = 0; $x < 3; $x++) {
        $c = 255 - hexdec(substr($color, (2 * $x), 2));
        $c = ($c < 0) ? 0 : dechex($c);
        $rgb .= (strlen($c) < 2) ? '0' . $c : $c;
    }
    $textColor = '#' . $rgb;
    return "color:{$textColor};background-color:#{$color};";
}
$css = "";
for($i = 0; $i < 1000; $i++) {
    $css .= "div.n{$i}{".getCss()."}";
}

echo $css;