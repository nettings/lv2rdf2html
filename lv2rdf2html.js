/* 
  lv2rdf2html.js 
  (C) 2017 Jörn Nettingsmeier
  licensed under the terms of the GNU GPL v3.
*/

const SLIDER_RESOLUTION=1024;

var pluginParameters;

$( function() {

};

function getPluginValues() {
  $.ajax({
        url:     "pluginController.php",
        settings: accepts: {
                             lv2data : 'application/x-lv2data'
                           },
                  cache:   false,
        FIXME
   });

}
function round(value, decimals) {
  var f = Math.pow(10, decimals);
  return Math.round(value * f)/f;
}
    
function lin2log(value, min, max) {
  var minval = Math.log(min);
  var maxval = Math.log(max);
  var ratio = (maxval - minval) / (SLIDER_RESOLUTION);
  return Math.exp(minval + ratio * value);
}
   
function log2lin(value, min, max) {
  var minval = Math.log(min);
  var maxval = Math.log(max);
  var ratio = (maxval - minval) / (SLIDER_RESOLUTION);
  return (Math.log(value) - minval) / ratio;
}
  