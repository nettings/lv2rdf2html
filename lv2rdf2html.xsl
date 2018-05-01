<?xml version="1.0"?>
<!--
  lv2rdf2html.xsl
  (C) 2017 by Jörn Nettingsmeier. Usage rights are granted according to the
  3-Clause BSD License (see COPYING).
  
  This is a horrible stylesheet. That is because there is no bijective mapping
  of Turtle triplets to XML - triplets can be grouped for brevity or not. Hence,
  each and every select statement starts over from the document root and matches via
  ID attributes. Oh the pain.
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

<xsl:param name="jsuri"/>
<xsl:param name="cssuri"/>

<xsl:template match="/*">
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
    <script src="{$jsuri}">&#8203;</script>
    <link rel="stylesheet" href="{$cssuri}" />
  </head>
  <body>
    <div id="ajaxDebug">
      AJAX Debugging: <a class="X" href="#" onclick="javascript:$('#ajaxDebug').css('display','none')">x</a>
      <div id="ajaxLog">
        <div id="ajaxTX">
          Transmitted: <span>&#8203;</span>
        </div>
        <div id="ajaxRX">
          Received: <span>&#8203;</span>
        </div>
      </div>
    </div>
    <div>
      <xsl:call-template name="iterateOverPlugins"/> 
    </div>
  </body>
</html>
</xsl:template>

<xsl:template name="handlePlugin">
  <div class="pluginGUI" id="plugin{.}">
    <h1>
      <xsl:value-of select="key('descriptionsByPluginID', current())/doap:name"/>
    </h1>
    <div class="info">
      <xsl:apply-templates select="key('descriptionsByPluginID', current())/rdfs:comment"/>
      <xsl:apply-templates select="key('descriptionsByPluginID', current())/doap:license"/>
      <xsl:apply-templates select="key('descriptionsByPluginID', current())/foaf:name"/>
    </div>
    <form>
      <xsl:call-template name="iterateOverPluginParameters"/>
    </form>
  </div>    
</xsl:template>


<xsl:template name="handlePluginParameter">
  <div class="formItem ">
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
