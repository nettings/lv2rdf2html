<?xml version="1.0"?>
<!--
  gui-elements.xsl
  (C) 2017 by Jörn Nettingsmeier. This transform is licensed under the
  GNU General Public License v3.
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
  <select id="{current()}" name="{key('descriptionsByNodeID', current())/lv2:symbol}">
    <!-- iterate over all descriptions belonging to the current nodeID. --> 
    <xsl:for-each select="key('descriptionsByNodeID', current())[lv2:scalePoint]">
      <option value="{key('descriptionsByNodeID', current()/lv2:scalePoint/@rdf:nodeID)/rdf:value}">
        <xsl:value-of select="key('descriptionsByNodeID', current()/lv2:scalePoint/@rdf:nodeID)/rdfs:label"/>
      </option>                     
    </xsl:for-each>
  </select>
</xsl:template>

<xsl:template name="pluginParameterCheckbox">
  <input type="checkbox">
    <xsl:if test="
      key('descriptionsByNodeID', current())/lv2:default 
      and 
      key('descriptionsByNodeID', current())//lv2:default != 0
    ">
      <xsl:attribute name="checked">checked</xsl:attribute>
    </xsl:if>
  </input>
</xsl:template>

<xsl:template name="pluginParameterSlider">
  <div class="slider" id="{current()}">&#8203;</div>
  <input 
    class="value" 
    id="{current()}_" 
    name="{key('descriptionsByNodeID', current())/lv2:symbol}"
    value="{key('descriptionsByNodeID', current())/lv2:default}"
    min="{key('descriptionsByNodeID', current())/lv2:minimum}"
    max="{key('descriptionsByNodeID', current())/lv2:maximum}"
  />
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
  <script type="text/javascript">
    <xsl:text>
$( function() {
  $( "#</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>" ).slider({
    value: round(log2lin(</xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:default"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum"/>
    <xsl:text>), 2),
    min: 0,
    max: SLIDER_RESOLUTION,
    step: 1,
    slide: function(event, ui) {
      $("#</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>_").val(round(lin2log(ui.value,</xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum"/>
    <xsl:text>), 2));
    }                       
  });
});
$("#</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>_").change(function () {
  var value = this.value;
  $("#</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>").slider("value", log2lin(value,</xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum"/>
    <xsl:text>));
});
    </xsl:text>
  </script>
</xsl:template>

<xsl:template name="pluginParameterSliderLin">
  <script type="text/javascript">
    <xsl:text>
$( function() {
  $( "#</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>" ).slider({
    value: </xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:default"/>
    <xsl:text>,
    min: </xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum"/>
    <xsl:text>,
    max: </xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum"/>
    <xsl:text>,
    step: (</xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum"/>
    <xsl:text> - </xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum"/>
    <xsl:text>) / SLIDER_RESOLUTION,
    slide: function(event, ui) {
      $("#</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>_").val(ui.value);  
    }                       
  });
});
$("#</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>_").change(function () {
  var value = this.value;
  $("#</xsl:text>
    <xsl:value-of select="current()"/>
    <xsl:text>").slider("value", value);
});
    </xsl:text>
  </script>
</xsl:template>

<xsl:template name="pluginParameterInput">
  <input 
    id="{current()}" 
    name="{key('descriptionsByNodeID', current())/lv2:symbol}"
    value="{key('descriptionsByNodeID', current())/lv2:default}"
    min="{key('descriptionsByNodeID', current())/lv2:minimum}"
    max="{key('descriptionsByNodeID', current())/lv2:maximum}"
  />  
  <div class="range">
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum"/>
    <xsl:text> &#8804; x &#8804; </xsl:text>
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum"/>   
  </div>    
</xsl:template>


</xsl:stylesheet>