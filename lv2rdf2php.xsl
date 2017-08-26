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
  <xsl:processing-instruction name="php">
    <xsl:text>
define("HOST", "192.168.1.21");
define("PORT", 5555);
$fp = fsockopen(HOST, PORT);
$plugin_parameters = array(); 
$i=0;
</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
foreach ($plugin_parameters as $uri => $params) {
  $i++;
  foreach ($params as $symbol => $value) {
    echo "$uri -> $symbol = $value\n";
    $req = 'param_get '.$i.' '.$symbol;
    echo "$req... :\n";
    fwrite($fp, $req);
    $res = fread($fp, 256);
    $res = preg_split('/ +/', $res, 3);
    $res[2] = substr($res[2],0,-1); // remove null termination
    echo "res[0]=$res[0]\n";
    echo "res[1]=$res[1]\n";
    echo "res[2]=$res[2]\n";
    $plugin_parameters[$uri][$symbol]=$res[2];
  }
} 
var_dump($plugin_parameters);
fclose($fp);
</xsl:text>
  </xsl:processing-instruction>
</xsl:template>


<xsl:template match="/rdf:RDF">
  <xsl:call-template name="iterateOverPlugins"/>
</xsl:template> 


<xsl:template name="handlePlugin">
  <xsl:text>
$plugin_parameters['</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>'] = [];
</xsl:text>
  <xsl:call-template name="iterateOverPluginParameters"/>
</xsl:template>


<xsl:template name="handlePluginParameter">
  <xsl:text>$plugin_parameters['</xsl:text>
  <xsl:value-of select="/rdf:RDF/rdf:Description[lv2:port/@rdf:nodeID = current()]/@rdf:about"/>
  <xsl:text>']['</xsl:text>
  <xsl:value-of select="key('descriptionsByNodeID', current())/lv2:symbol"/>
  <xsl:text>'] = 0;
</xsl:text>
</xsl:template>

</xsl:stylesheet>
