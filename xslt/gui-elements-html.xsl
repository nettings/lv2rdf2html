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
    name="{key('descriptionsByNodeID', current())/lv2:symbol}_"
  >
    <xsl:call-template name="tooltip"/>
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
</xsl:template>


<xsl:template name="pluginParameterCheckbox">
  <input 
    id="{current()}_"
    name="{key('descriptionsByNodeID', current())/lv2:symbol}_"
    type="checkbox" 
    value="1"
  >
    <xsl:call-template name="tooltip"/>
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
</xsl:template>


<xsl:template name="pluginParameterSlider">
  <!-- coefficient for lv2:sampleRate port property -->
  <xsl:param name="k">1.0</xsl:param>
  <div class="slider" id="{current()}_"><xsl:call-template name="tooltip"/>&#8203;</div>
  <input 
    id="{current()}" 
    class="value" 
    name="{key('descriptionsByNodeID', current())/lv2:symbol}"
    type="text"
    value="{key('descriptionsByNodeID', current())/lv2:default * $k}"
    min="{key('descriptionsByNodeID', current())/lv2:minimum * $k}"
    max="{key('descriptionsByNodeID', current())/lv2:maximum * $k}"
  >
    <xsl:attribute name="title">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:minimum * $k"/>
      <xsl:text> ; </xsl:text>
      <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:maximum * $k"/>
      <xsl:text>]</xsl:text> 
    </xsl:attribute>
  </input>
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
  <!-- noop (only the js changes) -->
</xsl:template>


<xsl:template name="pluginParameterSliderLin">
  <!-- noop (only the js changes) -->
</xsl:template>


<xsl:template name="pluginParameterInput">
  <input 
    id="{current()}" 
    name="{key('descriptionsByNodeID', current())/lv2:symbol}"
    value="{key('descriptionsByNodeID', current())/lv2:default}"
    min="{key('descriptionsByNodeID', current())/lv2:minimum}"
    max="{key('descriptionsByNodeID', current())/lv2:maximum}"
  >
    <xsl:call-template name="tooltip"/>
  </input>
</xsl:template>

<xsl:template name="tooltip">
  <xsl:if test="key('descriptionsByNodeID', current())/rdfs:comment">
    <xsl:attribute name="title">
      <xsl:value-of select="key('descriptionsByNodeID', current())/rdfs:comment"/>
    </xsl:attribute>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>