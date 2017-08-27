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

<xsl:key name="descriptionsByNodeID" match="/rdf:RDF/rdf:Description[@rdf:nodeID]" use="@rdf:nodeID"/>
<xsl:key name="descriptionsByAbout" match="/rdf:RDF/rdf:Description[@rdf:about]" use="@rdf:about"/>


<xsl:template name="iterateOverPlugins">
  <!-- iterate over each unique plugin URI -->
  <xsl:for-each select="
    /rdf:RDF/rdf:Description/@rdf:about[
      count(.. | key('descriptionsByAbout', .)[1]) = 1
    ]
  ">
    <xsl:call-template name="handlePlugin"/>
  </xsl:for-each>
</xsl:template>


<xsl:template name="iterateOverPluginParameters">
  <!-- iterate over all descriptions that belong to the current plugin URI -->
  <xsl:for-each select="key('descriptionsByAbout', current())/lv2:port/@rdf:nodeID">
     <!-- iterate over all InputPorts that are ControlPorts -->
     <xsl:for-each select="
       key('descriptionsByNodeID', current())[ 
         rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#InputPort'
         and 
         key('descriptionsByNodeID', current())[
           rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#ControlPort'
         ]
       ]/@rdf:nodeID
     ">
                 
<!-- FIXME: ideally, this should be sorted according to lv2:index. Currently, I can't even get simple sorting by "." to work...                 
       <xsl:sort select="." data-type="text" order="descending"/>
       <xsl:sort select="key('descriptionsByNodeID', current())[lv2:index]/lv2:index" data-type="number" order="descending"/> 
       <xsl:value-of select="key('descriptionsByNodeID', current())[lv2:index]/lv2:index"/>
       <xsl:value-of select="."/>
-->   
       
       <xsl:call-template name="handlePluginParameter"/>  
     </xsl:for-each>
  </xsl:for-each>
</xsl:template>


</xsl:stylesheet>
