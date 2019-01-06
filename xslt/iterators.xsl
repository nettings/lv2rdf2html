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
  <!-- Current plugin: iterate over all InputPorts... -->
  <xsl:for-each select="
    key('descriptionsByPluginID', current())[ 
      rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#InputPort' 
    ]/@rdf:nodeID
  "> 
    <!-- sort by lv2:index! -->
    <xsl:sort data-type="number"  select="//rdf:Description[@rdf:nodeID=current()]/lv2:index"/>
<!-- BAR:    <xsl:value-of select="//rdf:Description[@rdf:nodeID=current()]/lv2:index"/>
-->
    <!-- ...then iterate over all of those that are ControlPorts... -->
    <xsl:for-each select="key('descriptionsByNodeID', current())[
        rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#ControlPort'
      ]/@rdf:nodeID
    ">
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
      <xsl:sort select="key('descriptionsByNodeID', current())/lv2:index"/>
      <xsl:call-template name="handlePluginControlOutput"/>  
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>


<xsl:template name="iterateOverPluginAudioInputs">
  <xsl:param name="pluginID"/>
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
      <xsl:call-template name="handlePluginAudioInput">
        <xsl:with-param name="pluginID" select="$pluginID"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>


<xsl:template name="iterateOverPluginAudioOutputs">
  <xsl:param name="pluginID"/>
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
      <xsl:call-template name="handlePluginAudioOutput">
        <xsl:with-param name="pluginID" select="$pluginID"/>  
      </xsl:call-template>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>


</xsl:stylesheet>
