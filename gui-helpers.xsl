<?xml version="1.0"?>
<!--
  gui-helpers.xsl
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
    <xsl:otherwise>
      <xsl:comment>lv2rdf2html: unrecognized unit <xsl:copy-of select="."/>. Falling back to generic display.</xsl:comment>
      <xsl:value-of select="
        translate(
          substring(
            @rdf:resource, 39
          ), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        )
      "/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- matches plugin comments -->
<xsl:template match="rdf:Description[@rdf:about]/rdfs:comment">
  <p><xsl:value-of select="."/></p>
</xsl:template>

<!-- matches plugin parameter comments -->
<xsl:template match="rdf:Description[@rdf:nodeID]/rdfs:comment">
  <xsl:text> </xsl:text>
  <abbr title="{.}">&#8505;</abbr>
</xsl:template>

<xsl:template match="doap:license">
  <p>License: <xsl:value-of select="
      translate(
        substring(
          @rdf:resource, 36
        ), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      )
  "/></p>
</xsl:template>

<xsl:template match="foaf:name">
  <p>Author: <xsl:value-of select="."/></p>
</xsl:template>

</xsl:stylesheet>