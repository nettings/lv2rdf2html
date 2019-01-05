<?xml version="1.0"?>
<!--
  lv2rdf2js.xsl
  (C) 2017 by Jörn Nettingsmeier. Usage rights are granted according to the
  3-Clause BSD License (see COPYING).
-->  

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:doap="http://usefulinc.com/ns/doap#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:lv2="http://lv2plug.in/ns/lv2core#"
  xmlns:lv2units="http://lv2plug.in/ns/extensions/units#"
  xmlns:atom="http://lv2plug.in/ns/ext/atom#"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
  exclude-result-prefixes="xsl doap foaf lv2 lv2units atom owl rdf rdfs xsd"
>

<xsl:output 
  method="xml" 
  omit-xml-declaration="yes"
/>

<xsl:include href="iterators.xsl"/>
<xsl:include href="selectors.xsl"/>
<xsl:include href="gui-elements-js.xsl"/>

<xsl:param name="ajaxuri"/>

<xsl:template match="/*">
  <xsl:text>/* 
  lv2rdf2html.js 
  (C) 2017 by Jörn Nettingsmeier. Usage rights are granted according to the
  3-Clause BSD License (see COPYING).

*/

const SLIDER_RESOLUTION=1000;
const NUMBOX_DECIMALS=4;
const CONTROLLER = "</xsl:text><xsl:value-of select="$ajaxuri"/><xsl:text>"

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
  var update = { nodeID : nodeID, value : value };
  $( LOG_TX ).html(JSON.stringify(update));
  $.ajax({
    url : CONTROLLER,
    type : 'POST',
    data: update,
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

// execute the generated code below once the page DOM tree is ready: 

$( document ).ready(function() {

</xsl:text>
<xsl:call-template name="iterateOverPlugins"/>
<xsl:text>

  $( document ).tooltip();
  $( "#pluginList" ).accordion({
    header: "section.pluginGUI h1",
    collapsible: true,
    active: false
  });
  $( "#ajaxDebug" ).accordion({
    header: "h1",
    collapsible: true,
    heightStyle: "content",
    active: false
  }).draggable({
    appendTo: "body",
    containment: "window",
    stop: function(event, ui) {
        var top = ui.helper.offset(top) - $(window).scrollTop();
        ui.helper.css('position', 'fixed');
        ui.helper.css('top', top+"px");
    }
  });
  init();

});
 
  </xsl:text>
</xsl:template>

<xsl:template name="handlePlugin">
  <xsl:text>
// </xsl:text>
  <xsl:value-of select="key('descriptionsByPluginID', current())/@rdf:about"/>
  <xsl:text>
</xsl:text>
  <xsl:call-template name="iterateOverPluginParameters"/>
</xsl:template>

<xsl:template name="handlePluginParameter">
  <xsl:call-template name="selectPluginParameterHandler"/>
  <xsl:text>
  $( "label[for='</xsl:text><xsl:value-of select="current()"/><xsl:text>']" ).dblclick(function() {
    $( "#</xsl:text><xsl:value-of select="current()"/><xsl:text>" ).val($( "#</xsl:text><xsl:value-of select="current()"/><xsl:text>" ).data('default').toFixed(NUMBOX_DECIMALS));
    $( "#</xsl:text><xsl:value-of select="current()"/><xsl:text>" ).change();
  });
</xsl:text>
</xsl:template>

</xsl:stylesheet>
