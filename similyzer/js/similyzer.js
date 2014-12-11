/**
 * Created by Guy on 10/12/2014.
 */
var resultsReady = false;
function analyze() {
    locinput = $("#locinput").val();
    if(locinput == '') {
        $(".jumbotron").addClass("has-error");
        return false;
    }
    $("#analyze").attr("disabled", "disabled");
    changeMenu('analyzing');
    sendRequest('analyze:'+locinput);
    return true;
}
function changeMenu(type) {
    $.ajax({
        url: "data.rpc.php?action=getMenu&type=" + type,
        success: function (result) {
            $(".buttons").html(result);
        }
    });
}

function updateStatus() {
    $.ajax({
        url: "data.rpc.php?action=getStatus",
        success: function (result) {
            if(result == "resultsReady") {
                sendRequest('restart');
                showResults('file');
                resultsReady = true;
            }
            else if(result.indexOf("comparingDone") > -1) {
                sendRequest('restart');
                $.ajax({
                    url: "data.rpc.php?action=comparePair&response=" + result,
                    success: function (result) {
                        //alert(result);
                        $("#myModal").html(result);
                        //$('#myModal').modal('show');
                    }
                });
            }
            else
                $(".status").html(result);
        }
    });
}

function sendRequest(command) {
    $.ajax({
        url: "data.rpc.php?action=sendRequest&command=" + command,
        success: function (result) {
            return result;
        }
    });
}
function showResults(resFile) {
    changeMenu('results');
    showGraphResults(resFile);
}
function showGraphResults(resFile) {
    $(".container").html('');
    $(".container2").html('loading..');
    $.ajax({
        url: "data.rpc.php?action=graphResults&resFile=" + resFile,
        success: function (result) {
            $(".container2").html(result);
        }
    });
}
window.setInterval(function(){
    if(resultsReady == true) {
        $(".status").html('Server Status: <span class="glyphicon glyphicon-saved" aria-hidden="true"></span><br />Current Task: Analyzing done!');
        setTimeout(function () {
            updateStatus();
        }, 1000);
        resultsReady = false;
    }
    else
        updateStatus();
}, 1000);