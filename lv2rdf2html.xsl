<?xml version="1.0"?>
<!--
  lv2rdf2html.xsl
  (C) 2017 by Jörn Nettingsmeier. This transform is licensed under the
  GNU General Public License v3.
  
  This is a horrible stylesheet. That is because there is no bijective mapping
  of Turtle triplets to XML - triplets can be grouped for brevity or not. Hence,
  each and every select statement starts over from the document root. Oh the pain.
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

<xsl:output 
  method="xml" 
  omit-xml-declaration="yes"
/>

<xsl:include href="gui-elements.xsl"/>
<xsl:include href="gui-helpers.xsl"/>
<xsl:include href="iterators.xsl"/>


<xsl:template match="/">
<html> 
  <head>
    <meta charset="utf-8"/>
    <script
      src="https://code.jquery.com/jquery-3.2.1.min.js"
      integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
      crossorigin="anonymous">&#8203;
    </script>   
    <script
      src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"
      integrity="sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU="
      crossorigin="anonymous">&#8203;
    </script>
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" />
    <script src="lv2rdf2html.js">&#8203;</script>
    <link rel="stylesheet" href="lv2rdf2html.css" />
  </head>
  <body>
    <div>
      <xsl:apply-templates/>
    </div>
  </body>
</html>
</xsl:template>


<xsl:template match="/rdf:RDF">
  <xsl:call-template name="iterateOverPlugins"/> 
</xsl:template> 


<xsl:template name="handlePlugin">
  <div class="pluginGUI {.}">
    <h1>
      <xsl:value-of select="key('descriptionsByAbout', current())/doap:name"/>
    </h1>
    <div class="info">
      <xsl:apply-templates select="key('descriptionsByAbout', current())/rdfs:comment"/>
      <xsl:apply-templates select="key('descriptionsByAbout', current())/doap:license"/>
      <xsl:apply-templates select="key('descriptionsByAbout', current())/foaf:name"/>
    </div>
    <form>
     <xsl:call-template name="iterateOverPluginParameters"/>
    </form>
  </div>    
</xsl:template>


<xsl:template name="handlePluginParameter">
  <div class="formItem">
    <label for="{current()}">
      <xsl:apply-templates select="key('descriptionsByNodeID', current())/lv2:name"/>
      <xsl:apply-templates select="key('descriptionsByNodeID', current())/rdfs:comment"/>
    </label>
    <div class="input">
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
    </div>
    <div class="unit">
      <xsl:text>&#8203;</xsl:text>
      <xsl:apply-templates select="key('descriptionsByNodeID', current())/lv2units:unit"/>
    </div>
  </div>  
</xsl:template>


</xsl:stylesheet>
