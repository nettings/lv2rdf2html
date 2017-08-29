/* 
  lv2rdf2html.js 
  (C) 2017 by Jörn Nettingsmeier. Usage rights are granted according to the
  3-Clause BSD License (see COPYING).

*/

const SLIDER_RESOLUTION=1000;
const CONTROLLER = "pluginController.php";

const LOG_TX = '#ajaxTX span';
const LOG_RX = '#ajaxRX span';

var nodeIDs = {};

var updating = false;

function init() {
  getPluginData();
}

function renderAJAXStatus(msg) {
  var result = msg['status'] + " " + msg['statusText'] + "\n"; 
  result += "readyState: ";
  switch (msg['readyState']) {
    case 1: result += "loading"; break;
    case 2: result += "loaded"; break;
    case 3: result += "interactive"; break;
    case 4: result += "complete"; break;
  }
  result += ".\nresponseText: " + msg['responseText'] + ".\n";
  return result;
}

function getPluginData() {
  const request = 'getPluginData';
  $( LOG_TX ).html(request);
  $.ajax({
    dataType: "json",
    url: CONTROLLER,
    data: request,
    error: function(msg) {
      alert('getPluginData() failed.\n' + renderAJAXStatus(msg));
    },
    success: function (pluginData) {
      $( LOG_RX ).html(JSON.stringify(pluginData));
      nodeIDs = pluginData;
      updateWidgets();
    }
  });
} 

function updateWidgets() {
  updating = true;
  //alert("updateWidgets(): " + JSON.stringify(nodeIDs));
  $.each( nodeIDs, function( nodeID, data ) {
    if (typeof(nodeID) != 'undefined') {
      $( '#' + nodeID).val(data.value);
    }
  });
  // take a second pass to avoid missed updates due to race condition 
  setTimeout( function() {
    $.each ( nodeIDs, function (nodeID ) {
      $( '#' + nodeID).change();
    });
    updating = false;
  }, 500);
}

function setPluginData(nodeID, value) {
  if (updating) return;
  var updateIDs = { nodeID : nodeID, value : value };
  $( LOG_TX ).html(JSON.stringify(updateIDs));
  $.ajax({
    url : CONTROLLER,
    type : 'POST',
    data: updateIDs,
    dataType: 'json',
    async: true,
    error: function(msg) {
      alert('setPluginData("'+ nodeID + '", ' + value + ') failed.\n' + renderAJAXStatus(msg));
    },
    success: function(msg) {
      $( LOG_RX ).html(JSON.stringify(msg));
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
 
$( init );  