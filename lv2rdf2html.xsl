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

<xsl:include href="iterators.xsl"/>
<xsl:include href="gui-elements-html.xsl"/>
<xsl:include href="gui-helpers.xsl"/>

<xsl:param name="jsuri"/>
<xsl:param name="cssuri"/>
<xsl:param name="jqueryuri"/>
<xsl:param name="jqueryintegrity"/>
<xsl:param name="jqueryuiuri"/>
<xsl:param name="jqueryuiintegrity"/>

<xsl:template match="/*">
<html> 
  <head>
    <meta charset="utf-8"/>
    <script
      src="{$jqueryuri}"
      integrity="{$jqueryintegrity}"
      crossorigin="anonymous">&#8203;
    </script>
    <script
      src="{$jqueryuiuri}"
      integrity="{$jqueryuiintegrity}"
      crossorigin="anonymous">&#8203;
    </script>
    <link rel="stylesheet" href="{$jqueryuicssuri}" />
    <script src="{$jsuri}">&#8203;</script>
    <link rel="stylesheet" href="{$cssuri}" />
  </head>
  <body>
    <main id="pluginList">
      <xsl:call-template name="iterateOverPlugins"/> 
    </main>
    <footer id="ajaxDebug">
      <section>
        <h1>AJAX Debugging</h1>
        <div id="ajaxLog">
          <div id="ajaxTX">
            Transmitted: <span>&#8203;</span>
          </div>
          <div id="ajaxRX">
            Received: <span>&#8203;</span>
          </div>
        </div>
      </section>
    </footer>
  </body>
</html>
</xsl:template>

<xsl:template name="handlePlugin">
  <section class="pluginGUI" id="plugin{.}">
    <h1><xsl:value-of select="key('descriptionsByPluginID', current())/doap:name"/></h1>
    <div>
      <div class="info">
        <xsl:call-template name="license"/>
        <xsl:apply-templates select="key('descriptionsByPluginID', current())/foaf:name"/>
      </div>
      <div class="ports">
        <p>Audio inputs: <xsl:call-template name="iterateOverPluginAudioInputs"/></p>
      </div>
      <form>
        <xsl:call-template name="iterateOverPluginParameters"/>
      </form>
      <div class="ports">
        <p>Control outputs: <xsl:call-template name="iterateOverPluginControlOutputs"/></p>
        <p>Audio outputs: <xsl:call-template name="iterateOverPluginAudioOutputs"/></p>
      </div>
    </div>
  </section>    
</xsl:template>


<xsl:template name="handlePluginParameter">
  <fieldset>
    <label for="{current()}">
      <xsl:call-template name="tooltip"/>
      <xsl:apply-templates select="key('descriptionsByNodeID', current())/lv2:name"/>
      <xsl:apply-templates select="key('descriptionsByNodeID', current())/rdfs:comment"/>
    </label>
    <xsl:call-template name="selectPluginParameterHandler"/>
    <xsl:apply-templates select="key('descriptionsByNodeID', current())/lv2units:unit"/>
  </fieldset>  
</xsl:template>

<xsl:template name="handlePluginControlOutput">
  <span title="{key('descriptionsByNodeID', current())/lv2:symbol}">
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:name"/>
  </span>
</xsl:template>

<xsl:template name="handlePluginAudioInput">
  <span title="{key('descriptionsByNodeID', current())/lv2:symbol}">
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:name"/>
  </span>
</xsl:template>

<xsl:template name="handlePluginAudioOutput">
  <span title="{key('descriptionsByNodeID', current())/lv2:symbol}">
    <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:name"/>
  </span>
</xsl:template>

</xsl:stylesheet>
