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
  $( "#<xsl:value-of select="current()"/>" ).data('default', <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:default"/>);
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
    them.val(parseInt(value));
  <xsl:call-template name="setPluginDataFunc"/>
  });
</xsl:template>


<xsl:template name="pluginParameterCheckbox">
  $( "#<xsl:value-of select="current()"/>" ).data('default', <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:default"/>);
  $( "#<xsl:value-of select="current()"/>_" ).change(function () {
    us = $( "#<xsl:value-of select="current()"/>_" );
    them = $( "#<xsl:value-of select="current()"/>" );
    if (us.prop("checked")) {
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
    } else {
      them.prop('checked', false);
    }
    <xsl:call-template name="setPluginDataFunc"/>
  });
</xsl:template>


<xsl:template name="pluginParameterSlider">
  <!-- coefficient for lv2:sampleRate port property -->
  <xsl:param name="k">1.0</xsl:param>
  $( "#<xsl:value-of select="current()"/>" ).data('default', <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:default * $k"/>);
  <xsl:choose>
    <!-- logarithmic slider -->
    <xsl:when test="
      key('descriptionsByNodeID', current())/lv2:portProperty/@rdf:resource 
      = 'http://lv2plug.in/ns/ext/port-props#logarithmic'
    ">
      <xsl:call-template name="pluginParameterSliderLog">
        <xsl:with-param name="k" select="$k"/>
      </xsl:call-template>
    </xsl:when>
    <!-- non-logarithmic slider -->
    <xsl:otherwise>
      <xsl:call-template name="pluginParameterSliderLin">
        <xsl:with-param name="k" select="$k"/>
      </xsl:call-template>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:template>


<xsl:template name="pluginParameterSliderLog">
  <!-- coefficient for lv2:sampleRate port property -->
  <xsl:param name="k">1.0</xsl:param>
  $( "#<xsl:value-of select="current()"/>_" ).slider({
    value: log2lin($( "#<xsl:value-of select="current()"/>" ).data('default'), <xsl:value-of
        select="key('descriptionsByNodeID', current())/lv2:minimum * $k"/>, <xsl:value-of 
        select="key('descriptionsByNodeID', current())/lv2:maximum * $k"/>),
    min: 0,
    max: SLIDER_RESOLUTION,
    step: 1,
    slide: function(event, ui) {
      var value = lin2log(ui.value, <xsl:value-of
        select="key('descriptionsByNodeID', current())/lv2:minimum * $k"/>, <xsl:value-of 
        select="key('descriptionsByNodeID', current())/lv2:maximum * $k"/>);
      $("#<xsl:value-of
        select="current()"/>").val(value.toFixed(NUMBOX_DECIMALS));
      <xsl:call-template name="setPluginDataFunc"/>               
    }        
  });
  $( "#<xsl:value-of select="current()"/>" ).change(function () {
    var value = this.value;
    $("#<xsl:value-of
      select="current()"/>_").slider("value", log2lin(value, <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:minimum * $k"/>, <xsl:value-of
      select="key('descriptionsByNodeID', current())/lv2:maximum * $k"/>));
    <xsl:call-template name="setPluginDataFunc"/>
  });
</xsl:template>


<xsl:template name="pluginParameterSliderLin">
  <!-- coefficient for lv2:sampleRate port property -->
  <xsl:param name="k">1.0</xsl:param>
  $( "#<xsl:value-of select="current()"/>_" ).slider({
    value: $( "#<xsl:value-of select="current()"/>" ).data('default'),
    min:   <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum * $k"/>,
    max:   <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum * $k"/>,
    step:  (<xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:maximum * $k"/> - <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:minimum * $k"/>) / SLIDER_RESOLUTION,
    slide: function(event, ui) {
      var value = ui.value;
      $("#<xsl:value-of select="current()"/>").val(value.toFixed(NUMBOX_DECIMALS));
    <xsl:call-template name="setPluginDataFunc"/>
    }                       
  });
  $( "#<xsl:value-of select="current()"/>" ).change(function () {
    var value = this.value;
    $( "#<xsl:value-of select="current()"/>_" ).slider("value", value);
    <xsl:call-template name="setPluginDataFunc"/>
  });
</xsl:template>

<xsl:template name="pluginParameterInput">
<!-- FIXME: not implemented -->
</xsl:template>

<xsl:template name="setPluginDataFunc">
    <xsl:text>setPluginData( "</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>", value );</xsl:text>
</xsl:template>


</xsl:stylesheet>