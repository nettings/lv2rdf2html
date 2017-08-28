/* 
  lv2rdf2html.js 
  (C) 2017 Jörn Nettingsmeier
  licensed under the terms of the GNU GPL v3.
*/

const SLIDER_RESOLUTION=1000;
const CONTROLLER = "pluginController.php";


var updating = false;

function getPluginData() {
  updating = true;
  $.getJSON( CONTROLLER, "getPluginData", function (nodeIDs) {
    //alert(JSON.stringify(nodeIDs));
    $.each( nodeIDs, function( nodeID, data ) {
          if (typeof(nodeID) != 'undefined') {
            $( '#' + nodeID).val(data.value);
            // avoid calling method before initialisation is complete
            var tries = 0;
            var error;
            do {
              try {
                tries++;
                  $( '#' + nodeID).trigger("change");
              } catch(e) {
                setTimeout( function() {
                  error = e;
                }, 5);
              }
            } while (error);
            console.log('setting #' + nodeID + '(' + data.uri + '.' + data.symbol + ' => ' + data.value);
            console.log('\t...took ' + tries + ' attempts');
          }
    }); 
    //alert(JSON.stringify(pluginParameterIDs));
  }); 
  setTimeout( function() {
    updating = false;
  }, 50);
  };

function setPluginData(nodeID, value) {
  
  if (updating) return;
  
  var updateIDs = { nodeID : nodeID, value : value };
  
  $( '#ajaxDebug1' ).html("AJAXing..." + JSON.stringify(updateIDs) + "");
  $.ajax({
    url : CONTROLLER,
    type : 'POST',
    data: updateIDs,
    dataType: 'json',
    async: true,
    error: function(msg) {
      alert(JSON.stringify(msg));
    },
    success: function(msg) {
      $( '#ajaxDebug2' ).html("OK, Here's something:" + JSON.stringify(msg) + "");
    }
});
}

function round(value, decimals) {
  var f = Math.pow(10, decimals);
  return Math.round(value * f)/f;
}
    
function lin2log(value, min, max) {
  var minval = Math.log(min);
  var maxval = Math.log(max);
  var ratio = (maxval - minval) / SLIDER_RESOLUTION;
  return Math.exp(ratio * value + minval);
}
   
function log2lin(value, min, max) {
  var minval = Math.log(min);
  var maxval = Math.log(max);
  var ratio = (maxval - minval) / SLIDER_RESOLUTION;
  return (Math.log(value) - minval) / ratio;
}
 
$( getPluginData );  