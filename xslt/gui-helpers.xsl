<?xml version="1.0"?>
<!--
  gui-helpers.xsl
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

<xsl:template match="lv2units:unit">
  <xsl:choose>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#hz'">
      <abbr title="Hertz [1/s]">Hz</abbr>
    </xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#db'">
      <abbr title="deciBel">dB</abbr>
    </xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#coef'">
      <abbr title="generic coefficient">[coeff]</abbr> 
    </xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#ms'">
      <abbr title="milliseconds">ms</abbr>
    </xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#bpm'">
      <abbr title="beats per minute">BPM</abbr>
    </xsl:when>
    <xsl:when test="@rdf:nodeID">
      <!-- found in zam-plugins -->
      <abbr title="{key('descriptionsByNodeID', current()/@rdf:nodeID)/rdfs:label}">
        <xsl:value-of select="key('descriptionsByNodeID', @rdf:nodeID)/lv2units:symbol"/>
      </abbr>
    </xsl:when>
    <xsl:otherwise>
      <xsl:comment>lv2rdf2html: unrecognized unit <xsl:copy-of select="."/>. Falling back to generic display.</xsl:comment>
      <xsl:value-of select="
        translate(
          substring-after(
            'extensions/units#', @rdf:resource
          ), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        )
      "/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- matches plugin comments -->
<xsl:template match="rdf:Description[@rdf:about]/rdfs:comment">
<!--
  <p><xsl:value-of select="."/></p>
-->
</xsl:template>

<!-- matches plugin parameter comments -->
<xsl:template match="rdf:Description[@rdf:nodeID]/rdfs:comment">
<!--
  <xsl:text> </xsl:text>
  <abbr title="{.}">&#8505;</abbr>
-->
</xsl:template>

<xsl:template name="license">
  <xsl:for-each select="key('descriptionsByPluginID', current())/doap:license">
    <p>
      <xsl:text>License: </xsl:text> 
      <xsl:choose>
        <xsl:when test="not(@rdf:resource)">
          <xsl:text>not specified</xsl:text>
        </xsl:when>
        <!-- if it's a dead usefulinc URI, just display the last part in uppercase -->
        <xsl:when test="contains(@rdf:resource, 'usefulinc.com/doap/licenses')">
          <xsl:value-of select="
            translate(
              substring-after(
                @rdf:resource, 'licenses/'
              ), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            )
          "/>
        </xsl:when>
        <!-- if it's an opensource.org URI, display the last part in uppercase and link -->
        <xsl:when test="contains(@rdf:resource, 'opensource.org/licenses')">
          <a href="{@rdf:resource}"><xsl:value-of select="
            translate(
              substring-after(
                @rdf:resource, 'licenses/'
              ), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            )
          "/>&#x200b;</a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@rdf:resource"/>
        </xsl:otherwise> 
      </xsl:choose>
    </p>
  </xsl:for-each>
</xsl:template>

<xsl:template match="foaf:name">
  <p>Author: <xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="doap:maintainer">
  <p>Maintainer: <a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/>&#x200b;</a></p>
</xsl:template>


</xsl:stylesheet>