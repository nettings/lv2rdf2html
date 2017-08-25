<?xml version="1.0"?>
<!--
  lv2rdf2html.xsl v. 0.2.0
  written 2017 by Jörn Nettingsmeier. This transform is in the public domain.
  
  Converts LV2 plugin documentation in RDF/XML format to a simple form-based 
  HTML5/jquery-ui GUI. This is meant to control plugins running in mod-host via a telnet
  connection.
  
  This is a horrible stylesheet. That is because there is no bijective mapping
  of Turtle triplets to XML - triplets can be grouped for brevity or not. Hence,
  each and every select statement starts over from the document root. Oh the pain.
  
  This stylesheet has been developed and tested with RDF/XML generated in the 
  following way:
  
  0. Gather URI information of available plugins:
    #~> lv2ls
  1. Collect plugin documentation in a Turtle file (lv2info appends to a file):
    #~> rm output.ttl
    #~> lv2info -p output.ttl http://gareus.org/oss/lv2/fil4#stereo
    #~> lv2info -p output.ttl http://calf.sourceforge.net/plugins/Compressor
  2. Convert the turtle file to RDF/XML:
   a. Using http://www.l3s.de/~minack/rdf2rdf/:
    #~> java -jar rdf2rdf-1.0.1-2.3.1.jar output.ttl output.xml
   b. Using rapper (part of raptor/Redland):
    #~> rapper -o rdfxml -i turtle output.ttl > output2.xml
  3. Apply this stylesheet and prettyprint:
    #~> xsltproc lv2rdf2html.xsl output.xml | xsltproc xml-prettyprint.xsl - > output.html
    #~> xsltproc lv2rdf2html.xsl output2.xml | xsltproc xml-prettyprint.xsl - > output2.html
  
  It currently tries to support all LV2 features used by the plugins listed above.
    
  Rdf2rdf and rapper produce different RDF/XML: rdf2r2f tries to collate
  triplets (but does a horrible job of doing it in a consistent way), and rapper
  does the simple, clean thing of keeping every single triplet separate. Both work
  because the stylesheet doesn't make any assumptions about them being grouped, 
  that's why it's soo terrible.
  
  There is a very clean alternative converter at http://www.easyrdf.org/converter
  which appears to do perfect grouping, but I'm a bit wary of supporting it because
  it has namespace troubles and seems to make a few risky guesses...
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

<xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:preserve-space elements="xsl:text *"/>

<xsl:key name="descriptionsByNodeID" match="rdf:Description[@rdf:nodeID]" use="@rdf:nodeID"/>
<xsl:key name="descriptionsByAbout" match="rdf:Description[@rdf:about]" use="@rdf:about"/>

<xsl:template match="/">
<html>
  <head>
    <meta charset="utf-8"/>
    <script src="https://code.jquery.com/jquery-3.2.1.js">&#8203;</script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js">&#8203;</script>
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" />
    <script type="text/javascript">
  
function round(value, decimals) {
  var f = Math.pow(10, decimals);
  return Math.round(value * f)/f;
}
    
function lin2log(value, min, max) {
  var minpos = 0;
  var maxpos = 1000;
  var minval = Math.log(min);
  var maxval = Math.log(max);
  var ratio = (maxval - minval) / (maxpos - minpos);
  return Math.exp(minval + ratio * (value - minpos));
}
   
function log2lin(value, min, max) {
  var minpos = 0;
  var maxpos = 1000;
  var minval = Math.log(min);
  var maxval = Math.log(max);
  var ratio = (maxval - minval) / (maxpos - minpos);
  return (Math.log(value) - minval) / ratio + minpos;
}
  
    </script>
    <style type="text/css">
      <xsl:text>
form { 
  display: table; 
  border-collapse: separate;
  border-spacing: 1ex;
  border: 1px solid;
}
div.formItem { 
  display: table-row;
}
label { 
  display: table-cell; 
  width: 12em;
}
div.input {
  display: table-cell;
}
div.slider {
  display: inline-block;
  width: 11em;
}
input.value {
  width: 11ex;
  text-align: right;
  margin-left: 1ex;
  display: inline-block;
}
div.unit {
  display: table-cell;
  width: 6em;
}
div.comment {
  display: table-cell;
  font-style: italic;
  width: auto;
}
      </xsl:text>
    </style>
  </head>
  <body>
    <div>
      <xsl:apply-templates/>
    </div>
  </body>
</html>
</xsl:template>

<xsl:template match="/rdf:RDF">
  <!-- iterate over each unique plugin URI -->
  <xsl:for-each select="
    /rdf:RDF/rdf:Description[
      @rdf:about 
      and count(. | key('descriptionsByAbout', @rdf:about)[1]) = 1
    ]
  ">
    <div class="pluginGUI {@rdf:about}">
      <h1>
        <xsl:value-of select="
          /rdf:RDF/rdf:Description[
            @rdf:about = current()/@rdf:about
          ]/doap:name
        "/>
      </h1>
      <div class="info">
        <xsl:apply-templates select="
          /rdf:RDF/rdf:Description[
            @rdf:about = current()/@rdf:about
          ]/rdfs:comment
        "/>
        <xsl:apply-templates select="  
          /rdf:RDF/rdf:Description[
            @rdf:about = current()/@rdf:about
          ]/doap:license
        "/>
        <xsl:apply-templates select="  
          /rdf:RDF/rdf:Description[
            @rdf:about = current()/@rdf:about
          ]/foaf:name
        "/>
      </div>
      <form>

        <!-- iterate over all nodeIDs that belong to the current plugin -->
        <xsl:for-each select="
          /rdf:RDF/rdf:Description[
            @rdf:about = current()/@rdf:about
          ]
        ">

          <!-- iterate over all unique descriptions with this nodeID 
               which are both InputPort and ControlPort -->
          <xsl:for-each select="
            /rdf:RDF/rdf:Description[
              @rdf:nodeID = current()/lv2:port/@rdf:nodeID 
              and /rdf:RDF/rdf:Description[
                @rdf:nodeID = current()/lv2:port/@rdf:nodeID
              ]/rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#ControlPort'
              and /rdf:RDF/rdf:Description[
                @rdf:nodeID = current()/lv2:port/@rdf:nodeID
              ]/rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#InputPort'
              and count(. | key('descriptionsByNodeID', current()/lv2:port/@rdf:nodeID)[1]) = 1
            ]
          ">
            <div class="formItem">
              <label for="{current()/@rdf:nodeID}">
                <xsl:apply-templates select="
                  /rdf:RDF/rdf:Description[
                    @rdf:nodeID = current()/@rdf:nodeID 
                  ]/lv2:name
                "/>
              </label>
              <div class="input">&#8203;
              <xsl:choose>

                <!-- handle enumeration of options -->
                <xsl:when test="
                  /rdf:RDF/rdf:Description[
                    @rdf:nodeID = current()/@rdf:nodeID 
                  ]/lv2:portProperty/@rdf:resource = 'http://lv2plug.in/ns/lv2core#enumeration'
                ">
                  <select id="{current()/@rdf:nodeID}" name="{
                    /rdf:RDF/rdf:Description[
                      @rdf:nodeID = current()/@rdf:nodeID 
                    ]/lv2:symbol
                  }">

                    <!-- iterate over all descriptions belonging to the current nodeID. --> 
                    <xsl:for-each select="
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID and lv2:scalePoint
                      ]
                    ">
                      <option value="{
                        /rdf:RDF/rdf:Description[
                          @rdf:nodeID = current()/lv2:scalePoint/@rdf:nodeID
                        ]/rdf:value
                      }">
                        <xsl:value-of select="
                          /rdf:RDF/rdf:Description[
                            @rdf:nodeID = current()/lv2:scalePoint/@rdf:nodeID
                          ]/rdfs:label
                        "/>
                      </option>                     
                    </xsl:for-each>
                  </select>
                </xsl:when>
                
                <!-- boolean option: checkbox -->
                <xsl:when test="
                  /rdf:RDF/rdf:Description[
                    @rdf:nodeID = current()/@rdf:nodeID 
                  ]/lv2:portProperty/@rdf:resource = 'http://lv2plug.in/ns/lv2core#toggled'
                ">
                  <input type="checkbox" value="1"> 
                    <xsl:if test="
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:default 
                      and 
                        /rdf:RDF/rdf:Description[
                          @rdf:nodeID = current()/@rdf:nodeID 
                        ]/lv2:default 
                        != 0
                    ">
                      <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                  </input>
                </xsl:when>
                
                <!-- decimal value or integer range > 2: jQuery-ui slider -->
                <xsl:when test="
                  /rdf:RDF/rdf:Description[
                    @rdf:nodeID = current()/@rdf:nodeID 
                  ]/lv2:default/@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#decimal'
                  or (
                    /rdf:RDF/rdf:Description[
                      @rdf:nodeID = current()/@rdf:nodeID 
                    ]/lv2:default/@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#integer'
                    and (
                      (
                        /rdf:RDF/rdf:Description[
                          @rdf:nodeID = current()/@rdf:nodeID 
                        ]/lv2:maximum
                      - 
                        /rdf:RDF/rdf:Description[
                          @rdf:nodeID = current()/@rdf:nodeID 
                        ]/lv2:minimum
                      )
                      > 2
                    )
                  )
                ">
                  <div class="slider" id="{current()/@rdf:nodeID}">&#8203;</div>
                  <input 
                    class="value" 
                    id="{current()/@rdf:nodeID}_" 
                    value="{/rdf:RDF/rdf:Description[
                      @rdf:nodeID = current()/@rdf:nodeID 
                    ]/lv2:default}"
                  />
                <xsl:choose>
                
                  <!-- logarithmic slider -->
                  <xsl:when test="/rdf:RDF/rdf:Description[
                    @rdf:nodeID = current()/@rdf:nodeID 
                  ]/lv2:portProperty/@rdf:resource = 'http://lv2plug.in/ns/ext/port-props#logarithmic'">
                    <script type="text/javascript">
                      <xsl:text>
                      $( function() {
                        $( "#</xsl:text>
                      <xsl:value-of select="current()/@rdf:nodeID"/>
                      <xsl:text>" ).slider({
                          value: round(log2lin(</xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:default"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:minimum"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:maximum"/>
                      <xsl:text>), 2),
                          min: 1,
                          max: 1000,
                          step: 1,
                          slide: function(event, ui) {
                            $("#</xsl:text>
                      <xsl:value-of select="current()/@rdf:nodeID"/>
                      <xsl:text>_").val(round(lin2log(ui.value,</xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:minimum"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:maximum"/>
                      <xsl:text>), 2));
                          }                       
                        });
                      });
                      $("#</xsl:text>
                      <xsl:value-of select="current()/@rdf:nodeID"/>
                      <xsl:text>_").change(function () {
                        var value = this.value;
                        $("#</xsl:text>
                      <xsl:value-of select="current()/@rdf:nodeID"/>
                      <xsl:text>").slider("value", log2lin(value,</xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:minimum"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:maximum"/>
                      <xsl:text>));
                      });
                      </xsl:text>
                    </script>
                  </xsl:when>
                  
                  <!-- non-logarithmic slider -->
                  <xsl:otherwise>
                    <script type="text/javascript">
                      <xsl:text>
                      $( function() {
                        $( "#</xsl:text>
                      <xsl:value-of select="current()/@rdf:nodeID"/>
                      <xsl:text>" ).slider({
                          value: </xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:default"/>
                      <xsl:text>,
                          min: </xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:minimum"/>
                      <xsl:text>,
                          max: </xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:maximum"/>
                      <xsl:text>,
                          step: (</xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:maximum"/>
                      <xsl:text> - </xsl:text>
                      <xsl:value-of select="/rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:minimum"/>
                      <xsl:text>) / 1024,
                          slide: function(event, ui) {
                            $("#</xsl:text>
                      <xsl:value-of select="current()/@rdf:nodeID"/>
                      <xsl:text>_").val(ui.value);  
                          }                       
                        });
                      });
                      $("#</xsl:text>
                      <xsl:value-of select="current()/@rdf:nodeID"/>
                      <xsl:text>_").change(function () {
                        var value = this.value;
                        $("#</xsl:text>
                      <xsl:value-of select="current()/@rdf:nodeID"/>
                      <xsl:text>").slider("value", value);
                      });
                      </xsl:text>
                    </script>
                    </xsl:otherwise>    
                  </xsl:choose>
                </xsl:when>

                <xsl:otherwise>
                  <input id="{current()/@rdf:nodeID}" name="{/rdf:RDF/rdf:Description[
                    @rdf:nodeID = current()/@rdf:nodeID 
                  ]/lv2:symbol}"/>
                    
                </xsl:otherwise>
  
                 </xsl:choose>
                 </div>
                 <div class="unit">&#8203;
                   <xsl:apply-templates select="/rdf:RDF/rdf:Description[
                     @rdf:nodeID = current()/@rdf:nodeID 
                   ]/lv2units:unit"/>
                 </div>

                 <div class="comment">&#8203;<xsl:value-of select="
                   /rdf:RDF/rdf:Description[
                     @rdf:nodeID = current()/@rdf:nodeID 
                   ]/rdfs:comment
                 "/>
                 </div>  
               </div>  
               
            </xsl:for-each>
  
          </xsl:for-each>
        
        </form>
      </div>
    
    </xsl:for-each>
    
</xsl:template> 

<xsl:template match="lv2units:unit">
  <xsl:choose>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#hz'"><abbr title="Hertz [1/s]">Hz</abbr></xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#db'"><abbr title="deciBel">dB</abbr></xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#coef'"><abbr title="generic coefficient">[coeff]</abbr></xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#ms'"><abbr title="milliseconds">ms</abbr></xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#bpm'"><abbr title="beats per minute">BPM</abbr></xsl:when>
    <xsl:otherwise>
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

<xsl:template match="rdfs:comment">
  <p><xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="doap:license">
  <p>License:
    <xsl:value-of select="
      translate(
        substring(
          @rdf:resource, 36
        ), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      )
    "/>
  </p>
</xsl:template>

<xsl:template match="foaf:name">
  <p>Author: <xsl:value-of select="."/></p>
</xsl:template>

</xsl:stylesheet>
