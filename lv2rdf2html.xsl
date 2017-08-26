<?xml version="1.0"?>
<!--
  lv2rdf2html.xsl
  written 2017 by Jörn Nettingsmeier. This transform is in the public domain.
  
  Converts LV2 plugin documentation in RDF/XML format to a simple form-based 
  HTML5/jquery-ui GUI with a PHP backend. 
  This is meant to control plugins running embedded in a mod-host through a 
  telnet connection, but could be adapted to other uses easily.
  
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
        ...
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
  it requires PHP, fails to include namespace prefixes and seems to make a few risky guesses...
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


<xsl:template name="createPluginParameterGUI">
<xsl:text>
</xsl:text>            
<xsl:processing-instruction name="php">
    
$plugin_parameters['<xsl:value-of 
              select="/rdf:RDF/rdf:Description[lv2:port/@rdf:nodeID = current()/@rdf:nodeID]/@rdf:about"/>']['<xsl:value-of 
              select="/rdf:RDF/rdf:Description[@rdf:nodeID = current()/@rdf:nodeID]/lv2:symbol"/>'] = 0;
              
</xsl:processing-instruction>
            
            <div class="formItem">
              <label for="{current()/@rdf:nodeID}">
                <xsl:apply-templates select="
                  /rdf:RDF/rdf:Description[
                    @rdf:nodeID = current()/@rdf:nodeID 
                  ]/lv2:name
                "/>
                <xsl:if test="
                     /rdf:RDF/rdf:Description[
                       @rdf:nodeID = current()/@rdf:nodeID 
                     ]/rdfs:comment
                ">
                  <xsl:text> </xsl:text>
                  <abbr title="{
                     /rdf:RDF/rdf:Description[
                       @rdf:nodeID = current()/@rdf:nodeID 
                     ]/rdfs:comment
                  }">&#8505;</abbr>
                </xsl:if>
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
                
                <!-- decimal value or integer  > 2: jQuery-ui slider -->
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
                    name="{
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:symbol
                    }"
                    value="{
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:default
                    }"
                    min="{
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:minimum
                    }"
                    max="{
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:maximum
                    }"
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
                          min: 0,
                          max: SLIDER_RESOLUTION,
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
                      <xsl:text>) / SLIDER_RESOLUTION,
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
                  <xsl:comment>lv2rdf2html: unrecognized parameter type, falling back to data entry field.</xsl:comment>
                  <input 
                    id="{current()/@rdf:nodeID}" 
                    name="{
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:symbol
                    }"
                    value="{
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:default
                    }"
                    min="{
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:minimum
                    }"
                    max="{
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:maximum
                    }"
                  />  
                  <div class="range">
                    <xsl:value-of select=" 
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:minimum
                    "/>
                    <xsl:text> &lt;= x &lt;= </xsl:text>
                    <xsl:value-of select=" 
                      /rdf:RDF/rdf:Description[
                        @rdf:nodeID = current()/@rdf:nodeID 
                      ]/lv2:maximum
                    "/>   
                  </div>    
                </xsl:otherwise>
  
                 </xsl:choose>
                 </div>
                 <div class="unit">&#8203;<xsl:apply-templates select="/rdf:RDF/rdf:Description[
                     @rdf:nodeID = current()/@rdf:nodeID 
                   ]/lv2units:unit"/>
                 </div>
               </div>  
</xsl:template>

<xsl:template name="createPluginParameterList">
</xsl:template>

<xsl:template name="createPluginGUI">
<xsl:processing-instruction name="php">$plugin_parameters['<xsl:value-of select="@rdf:about"/>'] = [];</xsl:processing-instruction>
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
        <xsl:call-template name="iterateOverPluginParameters"/>
      </form>
    </div>    
</xsl:template>

<xsl:template name="createPluginList">
</xsl:template>

<xsl:template match="/">


<xsl:processing-instruction name="php">
<![CDATA[
define("HOST", "192.168.1.21");
define("PORT", 5555);
define("TIMEOUT", 3);
$errno = 0; 
$errmsg = '';
$usermsg = ''; 

$fp = fsockopen(HOST, PORT, $errno, $errmsg, 3);
stream_set_timeout($fp, TIMEOUT);
if (!$fp) {
  $usermsg = "Could not connect to mod-host at ".HOST.":".PORT." within a timeout of ".TIMEOUT." seconds. ERRNO='".$errno."', ERRMSG='".$errmsg."'.";
}
$plugin_parameters = array();
]]>
</xsl:processing-instruction>


<html>
  <head>
    <meta charset="utf-8"/>
    <script src="https://code.jquery.com/jquery-3.2.1.js">&#8203;</script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js">&#8203;</script>
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" />
    <script type="text/javascript">

const SLIDER_RESOLUTION=1024;

function round(value, decimals) {
  var f = Math.pow(10, decimals);
  return Math.round(value * f)/f;
}
    
function lin2log(value, min, max) {
  var minval = Math.log(min);
  var maxval = Math.log(max);
  var ratio = (maxval - minval) / (SLIDER_RESOLUTION);
  return Math.exp(minval + ratio * value);
}
   
function log2lin(value, min, max) {
  var minval = Math.log(min);
  var maxval = Math.log(max);
  var ratio = (maxval - minval) / (SLIDER_RESOLUTION);
  return (Math.log(value) - minval) / ratio;
}
  
    </script>
    <style type="text/css">
      <xsl:text>
div {
  border: 1px grey dotted;
}
div.pluginGUI {
  display: table;
}
div.pluginGUI h1 {
  display: table-row;
}
form { 
  display: row-group; 
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
input.value, div.range {
  width: 11ex;
  max-width: 11ex;
  text-align: right;
  margin-left: 1ex;
  display: inline-block;
}
div.range {
  font-size: 60%;
  font-weight: bold;
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
<xsl:processing-instruction name="php">echo "<h1>$usermsg</h1>";</xsl:processing-instruction>
    <div>
      <xsl:apply-templates/>
    </div>
  </body>
</html>
</xsl:template>

<xsl:template name="iterateOverPlugins">
  <!-- iterate over each unique plugin URI -->
  <xsl:for-each select="
    /rdf:RDF/rdf:Description[
      @rdf:about 
      and count(. | key('descriptionsByAbout', @rdf:about)[1]) = 1
    ]
  ">
    <xsl:call-template name="createPluginGUI"/>
  </xsl:for-each>
</xsl:template>


<xsl:template name="iterateOverPluginParameters">
  <!-- iterate over all descriptions that belong to the current plugin URI -->
  <xsl:for-each select="
    /rdf:RDF/rdf:Description[
      @rdf:about = current()/@rdf:about
    ]
  ">
     <!-- iterate over all unique descriptions of this nodeID 
          for which exist InputPort and ControlPort resources -->
     <xsl:for-each select="
       /rdf:RDF/rdf:Description[
         @rdf:nodeID = current()/lv2:port/@rdf:nodeID 
         and 
         /rdf:RDF/rdf:Description[
           @rdf:nodeID = current()/lv2:port/@rdf:nodeID
         ]/rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#ControlPort'
         and 
         /rdf:RDF/rdf:Description[
           @rdf:nodeID = current()/lv2:port/@rdf:nodeID
         ]/rdf:type/@rdf:resource = 'http://lv2plug.in/ns/lv2core#InputPort'
         and 
         count(. | key('descriptionsByNodeID', current()/lv2:port/@rdf:nodeID)[1]) = 1
       ]
     ">
        <xsl:sort select="
          /rdf:RDF/rdf:Description[
            @rdf:nodeID = current()/lv2:port/@rdf:nodeID 
          ]/lv2:index"
          data-type="number" 
        />
       <xsl:call-template name="createPluginParameterGUI"/>
     </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template match="/rdf:RDF">
  <xsl:call-template name="iterateOverPlugins"/>
  <div class="debug">
    <pre>

<xsl:text>
</xsl:text>
<xsl:processing-instruction name="php"> 

   $i=0;
   foreach ($plugin_parameters as $uri => $params) {
     $i++;
     foreach ($params as $symbol => $value) {
       echo "$uri -> $symbol = $value\n";
       $req = 'param_get '.$i.' '.$symbol;
       echo "$req... :\n";
       fwrite($fp, $req);
       $res = fread($fp, 256);
       $res = preg_split('/ +/', $res, 3);
       echo "res[0]=$res[0]\n";
       echo "res[1]=$res[1]\n";
       echo "res[2]=$res[2]\n";
          
       $plugin_parameters[$uri][$symbol]=$res[2];
           
      
     }
   } 
   var_dump($plugin_parameters);
   
     
   fclose($fp);

</xsl:processing-instruction>

    </pre>   
  </div>    
</xsl:template> 

<xsl:template match="lv2units:unit">
  <xsl:choose>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#hz'"><abbr title="Hertz [1/s]">Hz</abbr></xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#db'"><abbr title="deciBel">dB</abbr></xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#coef'"><abbr title="generic coefficient">[coeff]</abbr></xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#ms'"><abbr title="milliseconds">ms</abbr></xsl:when>
    <xsl:when test="@rdf:resource='http://lv2plug.in/ns/extensions/units#bpm'"><abbr title="beats per minute">BPM</abbr></xsl:when>
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

<xsl:template match="rdfs:comment">
  <p><xsl:value-of select="."/></p>
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
