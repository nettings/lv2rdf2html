<?xml version="1.0"?>
<!--
  iterators.xsl
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

<xsl:key name="descriptionsByNodeID" match="/*/rdf:RDF/rdf:Description[@rdf:nodeID]" use="@rdf:nodeID"/>
<xsl:key name="descriptionsByAbout" match="/*/rdf:RDF/rdf:Description[@rdf:about]" use="@rdf:about"/>
<xsl:key name="descriptionsByPluginID" match="/*/rdf:RDF/rdf:Description" use="ancestor::rdf:RDF/@pluginID"/>

<xsl:template name="iterateOverPlugins">
  <xsl:for-each select="/*/rdf:RDF/@pluginID">
    <xsl:call-template name="handlePlugin"/>
  </xsl:for-each>
</xsl:template>


<xsl:template name="iterateOverPluginParameters">
  <!-- iterate over all InputPorts... -->
  <xsl:for-each select="
    key('descriptionsByPluginID', current())[ 
      rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#InputPort'
    ]/@rdf:nodeID
  "> 
    <!-- ...then iterate over all those that are ControlPorts -->
    <xsl:for-each select="
      key('descriptionsByNodeID', current())[
        rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#ControlPort'
      ]/@rdf:nodeID
    ">
      <xsl:sort select="lv2:index"/>
      <xsl:call-template name="handlePluginParameter"/>  
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template name="iterateOverPluginControlOutputs">
  <xsl:for-each select="
    key('descriptionsByPluginID', current())[ 
      rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#OutputPort'
    ]/@rdf:nodeID
  "> 
    <xsl:for-each select="
      key('descriptionsByNodeID', current())[
        rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#ControlPort'
      ]/@rdf:nodeID
    ">
      <xsl:sort select="lv2:index"/>
      <xsl:call-template name="handlePluginControlOutput"/>  
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template name="iterateOverPluginAudioInputs">
  <xsl:for-each select="
      key('descriptionsByPluginID', current())[ 
      rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#InputPort'
    ]/@rdf:nodeID
  "> 
    <xsl:for-each select="
      key('descriptionsByNodeID', current())[
        rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#AudioPort'
      ]/@rdf:nodeID
    ">
      <xsl:sort select="lv2:index"/>
      <xsl:call-template name="handlePluginAudioInput"/>  
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template name="iterateOverPluginAudioOutputs">
  <xsl:for-each select="
      key('descriptionsByPluginID', current())[ 
      rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#OutputPort'
    ]/@rdf:nodeID
  "> 
    <xsl:for-each select="
      key('descriptionsByNodeID', current())[
        rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#AudioPort'
      ]/@rdf:nodeID
    ">
      <xsl:sort select="lv2:index"/>
      <xsl:call-template name="handlePluginAudioOutput"/>  
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>


<xsl:template name="selectPluginParameterHandler">
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
      <xsl:call-template name="pluginParameterSlider"/>
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
