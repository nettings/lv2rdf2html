<?xml version="1.0"?>
<!--
  gui-elements.xsl
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


<xsl:template name="pluginParameterEnumeration">

$( "#<xsl:value-of select="current()"/>_" ).change(function () {
  us = $( "#<xsl:value-of select="current()"/>_" );
  them = $( "#<xsl:value-of select="current()"/>" );
  var value = us.val();
  them.val(value);
  <xsl:call-template name="setPluginDataFunc"/>
});
$( "#<xsl:value-of select="current()"/>" ).change(function () {
  us = $( "#<xsl:value-of select="current()"/>" );
  them = $( "#<xsl:value-of select="current()"/>_" );
  var value = us.val();
  them.value = value;
});

</xsl:template>


<xsl:template name="pluginParameterCheckbox">

$( "#<xsl:value-of select="current()"/>_" ).change(function () {
  us = $( "#<xsl:value-of select="current()"/>_" );
  them = $( "#<xsl:value-of select="current()"/>" );
  if (us.is(":checked")) {
    them.val(1);
  } else {
    them.val(0);
  }
  var value = them.val();
  <xsl:call-template name="setPluginDataFunc"/>
});
$( "#<xsl:value-of select="current()"/>" ).change(function () {
  us = $( "#<xsl:value-of select="current()"/>" );
  them = $( "#<xsl:value-of select="current()"/>_" );
  var value = us.val();
  if (value == 1) {
    them.prop('checked', true);
    //console.log("#<xsl:value-of select="current()"/> checked");
  } else {
    them.removeAttr('checked', false);
    //console.log("#<xsl:value-of select="current()"/> unchecked");
  }
});

</xsl:template>


<xsl:template name="pluginParameterSlider">
  <xsl:choose>
    <!-- logarithmic slider -->
    <xsl:when test="
      key('descriptionsByNodeID', current())/lv2:portProperty/@rdf:resource 
      = 'http://lv2plug.in/ns/ext/port-props#logarithmic'
    ">
      <xsl:call-template name="pluginParameterSliderLog"/>
    </xsl:when>
    <!-- non-logarithmic slider -->
    <xsl:otherwise>
      <xsl:call-template name="pluginParameterSliderLin"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:template>


<xsl:template name="pluginParameterSliderLog">

$( function() {
  $( "#<xsl:value-of select="current()"/>_" ).slider({
    default: round(log2lin(<xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:default"/>, <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:minimum"/>, <xsl:value-of
      select="key('descriptionsByNodeID', current())/lv2:maximum"/>), 2),
    min: 0,
    max: SLIDER_RESOLUTION,
    step: 1,
    value: this.default,
    slide: function(event, ui) {
      var value = lin2log(ui.value, <xsl:value-of
        select="key('descriptionsByNodeID', current())/lv2:minimum"/>, <xsl:value-of 
        select="key('descriptionsByNodeID', current())/lv2:maximum"/>);
      $("#<xsl:value-of
        select="current()"/>").val(round(value, 2));
      <xsl:call-template name="setPluginDataFunc"/>               
    }        
  });
});
$( "#<xsl:value-of select="current()"/>" ).change(function () {
  var value = this.value;
  $("#<xsl:value-of
    select="current()"/>_").slider("value", log2lin(value, <xsl:value-of 
    select="key('descriptionsByNodeID', current())/lv2:minimum"/>, <xsl:value-of
    select="key('descriptionsByNodeID', current())/lv2:maximum"/>));
  <xsl:call-template name="setPluginDataFunc"/>
});

</xsl:template>


<xsl:template name="pluginParameterSliderLin">

$( function() {
  $( "#<xsl:value-of select="current()"/>_" ).slider({
    default: <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:default"/>,
    min:   <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum"/>,
    max:   <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum"/>,
    step:  (<xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:maximum"/> - <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:minimum"/>) / SLIDER_RESOLUTION,
    value: this.default,
    slide: function(event, ui) {
      var value = ui.value;
      $("#<xsl:value-of select="current()"/>").val(value);
    <xsl:call-template name="setPluginDataFunc"/>
    }                       
  });
});
$( "#<xsl:value-of select="current()"/>" ).change(function () {
  var value = this.value;
  $( "#<xsl:value-of select="current()"/>_" ).slider("value", value);
  <xsl:call-template name="setPluginDataFunc"/>
});

</xsl:template>

<xsl:template name="setPluginDataFunc">
    <xsl:text>setPluginData( "</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>", value );</xsl:text>
</xsl:template>

<xsl:template name="pluginParameterInput">
<!-- FIXME: not implemented -->
</xsl:template>


</xsl:stylesheet>