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
  <select 
    id="{current()}_" 
    name="{key('descriptionsByNodeID', current())/lv2:symbol}_">
    <!-- iterate over all descriptions belonging to the current nodeID. --> 
    <xsl:for-each select="key('descriptionsByNodeID', current())[lv2:scalePoint]">
      <option value="{key('descriptionsByNodeID', lv2:scalePoint/@rdf:nodeID)/rdf:value}">
        <xsl:if test="
          key('descriptionsByNodeID', lv2:scalePoint/@rdf:nodeID)/rdf:value 
            = key('descriptionsByNodeID', current())/lv2:default
          or (position() = 1 and not(key('descriptionsByNodeID', current())/lv2:default))
        ">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="key('descriptionsByNodeID', current()/lv2:scalePoint/@rdf:nodeID)/rdfs:label"/>
      </option>                     
    </xsl:for-each>
  </select>
  <input
    id="{current()}"
    name="{key('descriptionsByNodeID', current())/lv2:symbol}"
    type="hidden" 
    value="{key('descriptionsByNodeID', current())/lv2:default}"
  />
  <script>

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


  </script>
</xsl:template>


<xsl:template name="pluginParameterCheckbox">
  <input 
    id="{current()}_"
    name="{key('descriptionsByNodeID', current())/lv2:symbol}_"
    type="checkbox" 
    value="1"
  >
    <xsl:if test="
      key('descriptionsByNodeID', current())/lv2:default 
      and 
      key('descriptionsByNodeID', current())//lv2:default != 0
    ">
      <xsl:attribute name="checked">checked</xsl:attribute>
    </xsl:if>
  </input>
  <input
    id="{current()}"
    name="{key('descriptionsByNodeID', current())/lv2:symbol}"
    type="hidden" 
    value="{key('descriptionsByNodeID', current())/lv2:default}"
  />
  <script>  
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
  </script>
</xsl:template>


<xsl:template name="pluginParameterSlider">
  <div class="slider" id="{current()}_">&#8203;</div>
  <input 
    id="{current()}" 
    class="value" 
    name="{key('descriptionsByNodeID', current())/lv2:symbol}"
    type="text"
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
$( function() {
  $( "#<xsl:value-of select="current()"/>_" ).slider({
    value: round(log2lin(<xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:default"/>, <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:minimum"/>, <xsl:value-of
      select="key('descriptionsByNodeID', current())/lv2:maximum"/>), 2),
    min: 0,
    max: SLIDER_RESOLUTION,
    step: 1,
    stop: function(event, ui) {
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
  </script>
</xsl:template>


<xsl:template name="pluginParameterSliderLin">
  <script type="text/javascript">
$( function() {
  $( "#<xsl:value-of select="current()"/>_" ).slider({
    value: <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:default"/>,
    min:   <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum"/>,
    max:   <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum"/>,
    step:  (<xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:maximum"/> - <xsl:value-of 
      select="key('descriptionsByNodeID', current())/lv2:minimum"/>) / SLIDER_RESOLUTION,
    stop: function(event, ui) {
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
  </script>
</xsl:template>


<xsl:template name="setPluginDataFunc">
    setPluginData( "<xsl:value-of select="current()"/>", value );
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