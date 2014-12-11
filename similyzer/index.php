<?php
// Project: similyzer
// File: index.php
// Created by Guy@GSR (27/11/2014)
session_start();
session_destroy();

?>
<!DOCTYPE HTML>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>Highcharts Example</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script src="highcharts/js/highcharts.js"></script>
    <script src="highcharts/js/highcharts-more.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/similyzer.js"></script>
    <link href="css/similyzer.css" rel="stylesheet">
    <link href="css/ncolors.css" rel="stylesheet">
    <script src="js/prism.js"></script>
    <link href="css/prism.css" rel="stylesheet">

</head>
<body>
<div class="header">
    <div class="logo">
        <img src="images/logo.png" />
    </div>
    <div class="menu">
        <div class="buttons">
            <button type="button" class="btn btn-primary" onclick="window.location='index.php'">Choose Project</button>
            <button type="button" class="btn btn-default disabled">Analyze</span></button>
            <div class="btn-group">
                <button type="button" class="btn btn-default dropdown-toggle disabled" data-toggle="dropdown" aria-expanded="false">
                    Results <span class="caret"></span>
                </button>
                <ul class="dropdown-menu" role="menu">
                    <li><a href="#">Graph Output</a></li>
                    <li><a href="#">Plain Text Output</a></li>
                </ul>
            </div>
        </div>
        <div class="status">
            Loading..
        </div>
    </div>
    <div class="credit">
        University &nbsp;&nbsp;&nbsp;&nbsp;of&nbsp;&nbsp;&nbsp;&nbsp;Amsterdam<br />
        Guy Rombaut, Bas Meesters
    </div>
</div>

<!-- Main Page -->
<div class="container">
    <div class="jumbotron">
        <h1>Choose a project to find clones</h1>
        <input type="text" id="locinput" class="form-control input-lg" placeholder="project://example-project/src/HelloWorld.java">
        <p class="lead">Rascal Location format. Last search: project://example-project/src/HelloWorld.java</p>
        <p><button type="button" id="analyze" class="btn btn-lg btn-default" onclick="analyze();">Analyze Project</button></p>
    </div>
</div>
<div class="container2">
</div>

<!-- Modal -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">

</div>


</body>
</html>
