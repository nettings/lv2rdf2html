<?xml version="1.0"?>
<!--
  selectors.xsl
  (C) 2018 by Jörn Nettingsmeier. This transform is licensed under the
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


<xsl:template name="selectPluginParameterHandler">
  <!-- implement lv2:sampleRate -->
  <xsl:variable name="fs">
    <xsl:choose>
      <xsl:when  test="
        key('descriptionsByNodeID', current())[
          lv2:portProperty/@rdf:resource = 'http://lv2plug.in/ns/lv2core#sampleRate'
        ]
      ">48000</xsl:when>
      <xsl:otherwise>1.0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <!-- handle enumeration of options: dropdown -->
    <xsl:when test="
      key('descriptionsByNodeID', current())/lv2:portProperty/@rdf:resource 
      = 'http://lv2plug.in/ns/lv2core#enumeration'
    ">
      <xsl:call-template name="pluginParameterEnumeration"/>
    </xsl:when>
    <!-- handle boolean option: checkbox -->
    <xsl:when test="
      key('descriptionsByNodeID', current())/lv2:portProperty/@rdf:resource 
      = 'http://lv2plug.in/ns/lv2core#toggled'
    ">
      <xsl:call-template name="pluginParameterCheckbox"/>
    </xsl:when>
    <!-- handle decimal value: jQuery-ui slider -->
    <xsl:when test="
      key('descriptionsByNodeID', current())/lv2:default/@rdf:datatype 
      = 'http://www.w3.org/2001/XMLSchema#decimal'
    ">
      <xsl:call-template name="pluginParameterSlider">
        <xsl:with-param name="k" select="$fs"/>
      </xsl:call-template>
    </xsl:when>
    <!-- handle integer range > 2: jQuery-ui slider -->          
    <xsl:when test="
      key('descriptionsByNodeID', current())/lv2:default/@rdf:datatype 
      = 'http://www.w3.org/2001/XMLSchema#integer'
      and (
        ( key('descriptionsByNodeID', current())/lv2:maximum
          - key('descriptionsByNodeID', current())/lv2:minimum
        ) > 2
      )
    ">
      <xsl:call-template name="pluginParameterSlider"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:comment>lv2rdf2html: unrecognized parameter type, falling back to data entry field.</xsl:comment>
      <xsl:call-template name="pluginParameterInput"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
