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

<xsl:output method="xml" omit-xml-declaration="yes"/>
<xsl:preserve-space elements="xsl:text *"/>

<xsl:include href="gui-elements.xsl"/>
<xsl:include href="gui-helpers.xsl"/>

<xsl:key name="descriptionsByNodeID" match="rdf:Description[@rdf:nodeID]" use="@rdf:nodeID"/>
<xsl:key name="descriptionsByAbout" match="rdf:Description[@rdf:about]" use="@rdf:about"/>

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
    <script type="text/javascript" href="lv2rdf2html.js">&#8203;</script>
    <link rel="stylesheet" href="lv2rdf2html.css" />
  </head>
  <body>
<xsl:processing-instruction name="php">echo "<h1>$usermsg</h1>";</xsl:processing-instruction>
    <div>
      <xsl:apply-templates/>
    </div>
  </body>
</html>
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





<xsl:template name="createPluginParameterGUI">
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
        <!-- handle enumeration of options: dropdown -->
        <xsl:when test="
          /rdf:RDF/rdf:Description[
            @rdf:nodeID = current()/@rdf:nodeID 
          ]/lv2:portProperty/@rdf:resource = 'http://lv2plug.in/ns/lv2core#enumeration'
        ">
          <xsl:call-template name="pluginParameterEnumeration"/>
        </xsl:when>
        <!-- handle boolean option: checkbox -->
        <xsl:when test="
          /rdf:RDF/rdf:Description[
            @rdf:nodeID = current()/@rdf:nodeID 
          ]/lv2:portProperty/@rdf:resource = 'http://lv2plug.in/ns/lv2core#toggled'
        ">
          <xsl:call-template name="pluginParameterCheckbox"/>
        </xsl:when>
        <!-- handle decimal value: jQuery-ui slider -->
        <xsl:when test="
          /rdf:RDF/rdf:Description[
            @rdf:nodeID = current()/@rdf:nodeID 
          ]/lv2:default/@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#decimal'
        ">
          <xsl:call-template name="pluginParameterSlider"/>
        </xsl:when>
        <!-- handle integer range > 2: jQuery-ui slider -->          
        <xsl:when test="
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
      &#8203;
      <xsl:apply-templates select="
        /rdf:RDF/rdf:Description[
          @rdf:nodeID = current()/@rdf:nodeID 
        ]/lv2units:unit
      "/>
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

</xsl:stylesheet>
