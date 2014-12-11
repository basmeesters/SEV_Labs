<?php
// Project: similyzer
// File: data.rpc.php 
// Created by Guy@GSR (09/12/2014)
session_start();
$action = $_GET['action'];
if(empty($action))
    exit(1);
include "core.class.php";
//include "comm.class.php";

switch($action){
    case "comparePair":
        $response = $_GET['response'];
        $data = explode('::', $response);
        echo core::comparePair($data[1], $data[2],$data[3]);
        break;
    case "getMenu":
        $type = $_GET['type'];
        echo core::showButtons($type);
        break;
    case "getStatus":
        echo core::getStatus();
        break;
    case "sendRequest":
        $command = $_GET['command'];
        echo core::sendRequest($command);
        break;
    case "graphResults":
        $resFile = $_GET['resFile'];
        echo core::graphResults($resFile);
        break;
//    case "communicate":
//        $command = $_GET['command'];
//        $ssid = $_GET['ssid'];
//        $com = new comm();
//
//        break;
    default:
        exit(1);
        break;
}