<?php
// Project: similyzer
// File: core.class.php
// Created by Guy@GSR (09/12/2014)

class core {

    public static function generateColors() {

        $rand = array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f');
        $color = $rand[rand(0,15)].$rand[rand(0,15)].$rand[rand(0,15)].$rand[rand(0,15)].$rand[rand(0,15)].$rand[rand(0,15)];

        // text color
        $color = str_replace('#', '', $color);
        if (strlen($color) != 6){ return '000000'; }
        $rgb = '';
        for ($x=0;$x<3;$x++){
            $c = 255 - hexdec(substr($color,(2*$x),2));
            $c = ($c < 0) ? 0 : dechex($c);
            $rgb .= (strlen($c) < 2) ? '0'.$c : $c;
        }
        $textColor = '#'.$rgb;
        $css = "color:{$textColor}; background-color:#{$color};";
        return $css;
    }

    public static function comparePair($filePathA, $filePathB, $type) {
        ob_start();
        $fileA = file_get_contents("communicator/f1Type{$type}.data");
        $fileA = htmlspecialchars($fileA);
        $fileA = str_replace('&lt;highlight-me', '<div', $fileA);
        $fileA = str_replace('highlight-me-end&gt;', '>', $fileA);
        $fileA = str_replace('&lt;/highlight-me&gt;', '</div>', $fileA);
        $fileB = "";
        $sameFile = true;
        if($filePathA != $filePathB) {
            $fileB = file_get_contents("communicator/f2Type{$type}.data");
            $fileB = htmlspecialchars($fileB);
            $fileB = str_replace('&lt;highlight-me', '<div', $fileB);
            $fileB = str_replace('highlight-me-end&gt;', '>', $fileB);
            $fileB = str_replace('&lt;/highlight-me&gt;', '</div>', $fileB);
            $sameFile = false;
        }
        ?>
        <div class="modal-dialog">
            <div class="modal-content"<?php if($sameFile) echo ' style="width:100%;"'; ?>>
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                    <h4 class="modal-title" id="myModalLabel"><?php echo $filePathA; ?></h4>
                </div>
                <div class="modal-body modalLeft">
                    <script src="js/prism.js"></script>
                    <pre>
                        <code class="language-java">
                            <?php echo $fileA; ?>
                        </code>
                    </pre>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
                </div>
            </div>
            <div class="modal-content"<?php if($sameFile) echo ' style="display:none;"'; ?>>
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                    <h4 class="modal-title" id="myModalLabel"><?php echo $filePathB; ?></h4>
                </div>
                <div class="modal-body modalRight">
                    <pre>
                        <code class="language-java">
                            <?php echo $fileB; ?>
                        </code>
                    </pre>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
                    <!-- <button type="button" class="btn btn-primary">Save changes</button> -->
                </div>
            </div>
        </div>
        <?php
        return ob_get_clean();
    }

    public static function sendRequest($command) {
        $location = explode(":", $command, 2);
        if(isset($location[1]) && $location[0] == 'analyze') {
            $_SESSION['location'] = $location[1];
        }
        file_put_contents("communicator/requests.data", $command, FILE_APPEND);
        return true;
    }

    public static function getStatus() {
        $file = "communicator/responses.data";
        $data = file($file);
        if(!isset($data[0]))
            $line = "standby::Server is Sleeping..";
        else
            $line = $data[count($data)-1];
        $response = explode("::", $line, 2);
        $serverIcon = "";
        switch($response[0]) {
            case "error":
            case "stop":
                $serverIcon = "exclamation-sign";
                break;
            case "test":
                $serverIcon = "ok";
                break;
            case "standby":
                $serverIcon = "flash";
                break;
            case "restart":
                $serverIcon = "refresh";
                break;
            case "analyzingDone":
                return "resultsReady";
                break;
            case "comparing":
            case "analyzing":
                $rand = rand(0,1);
                if($rand == 0)
                    $serverIcon = "resize-small";
                if($rand == 1)
                    $serverIcon = "resize-full";
                break;
            default:
                $serverIcon = "sort";
                break;
        }
        if(strpos($response[0], 'comparingDone') !== false)
            return $line;
        ob_start();
        ?>
        Server Status: <span class="glyphicon glyphicon-<?php echo $serverIcon; ?>" aria-hidden="true"></span>
        (<a href="#" onclick="sendRequest('stop');">Stop</a>, <a href="#" onclick="sendRequest('restart');">Restart</a>, <a href="#" onclick="sendRequest('testRes');">Test</a>)<br />
        Current Task: <?php echo $response[1]; ?>
        <?php
        return ob_get_clean();
    }

    public static function showButtons($type) {
        ob_start();
        if($type == "analyzing") {
        ?>
            <button type="button" class="btn btn-default disabled" onclick="window.location='index.php'">Choose Project <span class="glyphicon glyphicon-ok" aria-hidden="true"></button>
            <button type="button" class="btn btn-danger">Analyzing <img src="images/loading_small.gif" /></button>
            <div class="btn-group">
                <button type="button" class="btn btn-default dropdown-toggle disabled" data-toggle="dropdown" aria-expanded="false">
                    Results <span class="caret"></span>
                </button>
                <ul class="dropdown-menu" role="menu">
                    <li><a href="#">Graph Output</a></li>
                    <li><a href="#">Plain Text Output</a></li>
                </ul>
            </div>
        <?php
        }
        if($type == "results") {
            ?>
            <button type="button" class="btn btn-default" onclick="window.location='index.php'">Choose Project <span class="glyphicon glyphicon-ok" aria-hidden="true"></button>
            <button type="button" class="btn btn-default">Analyzed <span class="glyphicon glyphicon-ok" aria-hidden="true"></button>
            <div class="btn-group">
                <button type="button" class="btn btn-success dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                    Results <span class="caret"></span>
                </button>
                <ul class="dropdown-menu" role="menu">
                    <li><a href="#">Graph Output</a></li>
                    <li><a href="#">Plain Text Output</a></li>
                </ul>
            </div>
        <?php
        }
        return ob_get_clean();
    }

    protected static function getDuplicatesString($files, $type) {
        $jsTypeOneString = "";
        if(!file_exists("communicator/resultsType{$type}.data"))
            return "";
        $typeOneFile = file("communicator/resultsType{$type}.data", FILE_IGNORE_NEW_LINES);
        foreach($typeOneFile as $line) {
            $typeOneLine = explode(',', $line);
            $f1 = $files[$typeOneLine[0]];
            $f2 = $files[$typeOneLine[1]];
            $f3 = $typeOneLine[2];
            $jsTypeOneString .= "[$f1, $f2, $f3],";
        }
        return $jsTypeOneString;
    }

    public static function graphResults($resFile) {
        $graphTitle = "Clones Analalysis for testProject";

        // get all project locations
        $files = file("communicator/locations.data", FILE_IGNORE_NEW_LINES);
        $files = array_flip($files);

        $jsFilesString = "";
        foreach($files as $path => $pos) {
            $jsFilesString .= "['$path'],";
        }

        $jsTypeOneString = self::getDuplicatesString($files, 1);
        $jsTypeTwoString = self::getDuplicatesString($files, 2);
        $jsTypeThreeString = self::getDuplicatesString($files, 3);

        ob_start();
    ?>
    <div id="container" style="width: 100%; height: 90%; margin: 0 auto;"></div>
    <script type="text/javascript">
        var axisCategories = [<?php echo $jsFilesString; ?>];
//        var axisCatLines = [<?php //echo $jsDupsLinesString; ?>//];
        function codeComparison(xAxisCat, yAxisCat, clonesType) {

            sendRequest('comparePair:' + xAxisCat + '::' + yAxisCat + '::' + clonesType);
            $("#myModal").html('loading..');
            $('#myModal').modal('show');

//        alert(xAxisCat + " <->" + yAxisCat);
        }
        $(function () {
            $('#container').highcharts({
                chart: {
                    type: 'bubble',
                    plotBorderWidth: 5,
                    zoomType: 'xy'
                },
                "credits": {
                    "enabled": false
                },
                title: {
                    text: '<?php echo $graphTitle; ?>'
                },
                tooltip:{
                    formatter:function(){
                        return  '<b>Clone ' + this.series.name + '</b><br />' + 'File 1: <b>' + this.key + '</b><br />File 2: <b>' + axisCategories[this.y] + '</b><br />Size: <b>' + this.point.z + '</b>';
                    }
                },
                xAxis: {
                    gridLineWidth: 1,
                    categories: axisCategories,
                    tickmarkPlacement: 'on',
                    labels: {
                        formatter: function () {
                            return '<div class="graph-labels" title="' + this.value + '">' + this.value + '</div>';
                        },
                        useHTML: true,
                        rotation: -90
                    }
                },
                yAxis: {
                    startOnTick: false,
                    endOnTick: false,
                    categories: axisCategories,
                    title: {text : ""},
                    tickmarkPlacement: 'on',
                    labels: {
                        formatter: function () {
                            return '<div class="graph-labels" title="' + this.value + '">' + this.value + '</div>';
                        },
                        useHTML: true
                    }
                },

                series: [{
                    name: "Type 1",
                    data: [<?php echo $jsTypeOneString; ?>],
                    point: {
                        events: {
                            click: function () {
                                codeComparison(axisCategories[this.x], axisCategories[this.y], this.series._i+1);
//                            alert('Category: ' + this.category + ', value: ' + this.y);
                            }
                        }
                    },
                    marker: {
                        fillColor: 'rgba(69,114,167,0.5)'
//                    fillColor: {
//                        radialGradient: { cx: 0.4, cy: 0.3, r: 0.7 },
//                        stops: [
//                            [0, 'rgba(255,255,255,0.5)'],
//                            [1, 'rgba(69,114,167,0.5)']
//                        ]
//                    }
                    }
                }, {
                    name: "Type 2",
                    data: [<?php echo $jsTypeTwoString; ?>],
                    point: {
                        events: {
                            click: function () {
                                codeComparison(axisCategories[this.x], axisCategories[this.y], this.series._i+1);
//                            alert('Category: ' + this.category + ', value: ' + this.y);
                            }
                        }
                    },
                    color: 'rgba(170,70,67,0.5)',
                    marker: {
                        fillColor: 'rgba(170,70,67,0.5)'
                    }
                }, {
                    name: "Type 3",
                    data: [<?php echo $jsTypeThreeString; ?>],
                    point: {
                        events: {
                            click: function () {
                                codeComparison(axisCategories[this.x], axisCategories[this.y], this.series._i+1);
//                            alert('Category: ' + this.category + ', value: ' + this.y);
                            }
                        }
                    },
                    marker: {
                        fillColor: 'rgba(144,237,125,0.5)'
                    }
                }]

            });
        });
        //    alert(Highcharts.Color(Highcharts.getOptions().colors[2]).setOpacity(0.5).get('rgba'));
    </script>
    <?php
        return ob_get_clean();
    }
} 