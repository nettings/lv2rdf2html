<?xml version="1.0"?>
<!--
  lv2rdf2php.xsl
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

<xsl:output
  method="xml" 
  omit-xml-declaration="yes"
/>

<xsl:include href="gui-elements.xsl"/>
<xsl:include href="gui-helpers.xsl"/>
<xsl:include href="iterators.xsl"/>


<xsl:template match="/">

  <xsl:processing-instruction name="php">
define("HOST", "192.168.1.21");
define("PORT", 5555);
$fp = fsockopen(HOST, PORT);
$req = "";
$res = "";
$nodeIDs = array(); 
$instance = 0;

    <xsl:apply-templates/>

if (isset($_POST['nodeID'])) {
   $req = "param_set " . $nodeIDs[$_POST['nodeID']]['instanceNo'] . " " . $nodeIDs[$_POST['nodeID']]['symbol'] . " " . $_POST['value'];
   fwrite($fp, $req);
   $res = fread($fp, 256);
   $res = substr($res,0,-1); // remove null termination
   header('Content-Type: application/json');
   echo json_encode($req . " : " . $res);
   exit;
}


foreach ($nodeIDs as $nodeID => $data) {
  //echo $nodeID . " => " . " { instanceNo: " . $data['instanceNo'] . ", symbol: " . $data['symbol'] . ", value: " . $data['value'] . ", uri: " . $data['uri']. " }\n";
  $req = "param_get " . $data['instanceNo'] . " " . $data['symbol'];
  //echo "$req... :\n";
  fwrite($fp, $req);
  $res = fread($fp, 256);
  $res = preg_split('/ +/', $res, 3);
  $res[2] = substr($res[2],0,-1); // remove null termination
  //echo "res[0]=$res[0]\n";
  //echo "res[1]=$res[1]\n";
  //echo "res[2]=$res[2]\n";
  $nodeIDs[$nodeID]['value'] = $res[2];

} 

if (isset($_GET['getPluginData'])) {
  header('Content-Type: application/json');
  echo json_encode($nodeIDs);
} else if (isset($_GET['DEBUG'])) {
  var_dump($nodeIDs);
} 
fclose($fp);
</xsl:processing-instruction>
</xsl:template>


<xsl:template match="/rdf:RDF">
  <xsl:call-template name="iterateOverPlugins"/>
</xsl:template> 


<xsl:template name="handlePlugin">
  <xsl:text>
$instance++;
</xsl:text>
  <xsl:call-template name="iterateOverPluginParameters"/>
</xsl:template>


<xsl:template name="handlePluginParameter">
  $nodeIDs['<xsl:value-of select="current()"/>'] = array();
  $nodeIDs['<xsl:value-of select="current()"/>']['instanceNo'] = $instance;
  $nodeIDs['<xsl:value-of select="current()"/>']['symbol'] = "<xsl:value-of select="key('descriptionsByNodeID', current())/lv2:symbol"/>";
  $nodeIDs['<xsl:value-of select="current()"/>']['value'] = "<xsl:value-of select="key('descriptionsByNodeID', current())/lv2:default"/>";
  $nodeIDs['<xsl:value-of select="current()"/>']['uri'] = "<xsl:value-of select="/rdf:RDF/rdf:Description[lv2:port/@rdf:nodeID = current()]/@rdf:about"/>";
</xsl:template>

</xsl:stylesheet>
