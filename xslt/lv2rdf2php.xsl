<?xml version="1.0"?>
<!--
  lv2rdf2php.xsl
  (C) 2017 by Jörn Nettingsmeier. This transform is licensed under the
  GNU General Public License v3.
  
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

<xsl:param name="host"/>
<xsl:param name="port"/>

<xsl:include href="iterators.xsl"/>


<xsl:template match="/*">

  <xsl:processing-instruction name="php">
define("HOST", '<xsl:value-of select="$host"/>');
define("PORT", '<xsl:value-of select="$port"/>');
$errno = 0;
$errstr = "";
@$fp = fsockopen(HOST, PORT, $errno, $errstr);
if (!$fp) {
  header('Could not connect to mod-host.', true, 503);
  echo 'Error No. ' . $errno . ': Could not connect to mod-host. Error message is "' . $errstr .'".';
  exit;
}
$req = "";
$res = "";
$nodeIDs = array(); 
$instance = 0;

  <xsl:call-template name="iterateOverPlugins"/>

if (isset($_POST['nodeID'])) {
   // We are updating a single parameter.
   // Be sure to sanitize user-generated input. We assume using it as an array index is safe.
   // Strings used verbatim must be sanitized.
   $req = "param_set " 
   	. $nodeIDs[$_POST['nodeID']]['instanceNo'] . " " 
   	. $nodeIDs[$_POST['nodeID']]['symbol'] . " " 
   	. filter_var($_POST['value'], FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
   fwrite($fp, $req);
   $res = fread($fp, 256);
   $res = substr($res, 0, -1); // remove null termination
   $retval = substr($res, 5); // assume "resp N"
   if ($retval == 0) { 
     // default case, all is well
     header('Content-Type: application/json');
     echo json_encode($req . " completed successfully.");
   } else if ($retval > 0) {
     // only for newly instantiated plugins (not implemented yet in the frontend)
     header('Content-Type: application/json');
     echo json_encode($retval);
   } else if ($retval &lt; 0) {
     header('mod-host command error ' . $retval, true, 503);
     echo 'mod-host command error ' . $retval;
   } else {
     header('Unknown mod-host command error: ' . $res, true, 503);
     echo 'Unknown mod-host command error: ' . $res;
   }
   exit; // Terminate processing, we're done.
}

// We are interested in all current parameters. Get them:

foreach ($nodeIDs as $nodeID => $data) {
  $req = "param_get " . $data['instanceNo'] . " " . $data['symbol'];
  //echo "$req... : ";
  fwrite($fp, $req);
  $res = fread($fp, 256);
  $res = substr($res,0,-1); // remove null termination
  //echo "$res";
  $res = preg_split('/ +/', $res, 3); // split along spaces
  $last = count($res) - 1; // we expect the payload as the last token
  $nodeIDs[$nodeID]['value'] = $res[$last];
} 

// honor dumpPersistenceCommands for now, but it's deprecated!
if (isset($_GET['dumpPersistenceCommands']) || isset($_GET['dumpAllValues'])) {
  // System queries us for command list to restore current state.
  header('Content-Type: text/plain');
  foreach($nodeIDs as $nodeID) {
    echo "param_set ".$nodeID['instanceNo']." ".$nodeID['symbol']." ".$nodeID['value']."\n";
  }
  exit; // Terminate, we're done.
}

if (isset($_GET['dumpChangedValues'])) {
  // System queries us for command list to restore current state.
  header('Content-Type: text/plain');
  foreach($nodeIDs as $nodeID) {
    // only dump non-default values:
    if ($nodeID['value'] != $nodeID['default']) {
      echo "param_set ".$nodeID['instanceNo']." ".$nodeID['symbol']." ".$nodeID['value']."\n";
    }
  }
  exit; // Terminate, we're done.
}

if (isset($_GET['getPluginData'])) {
  // Front-end wants to know all values.
  header('Content-Type: application/json');
  echo json_encode($nodeIDs);
  exit; // Terminate, we're done.
}
if (isset($_GET['DEBUG'])) {
  // Developer wants a human-readable dump:
</xsl:processing-instruction>
<html>
  <head>
    <title>DEBUG</title>
  </head>
  <body>
    <div>
      <pre>
<xsl:processing-instruction name="php">
        var_dump($nodeIDs);
</xsl:processing-instruction>
      </pre>
    </div>
  </body>
</html>
<xsl:processing-instruction name="php">     
} 
fclose($fp);
</xsl:processing-instruction>
</xsl:template>

<xsl:template name="handlePlugin">
  <xsl:text>
$instance = </xsl:text><xsl:value-of select="."/><xsl:text>;
</xsl:text>
  <xsl:call-template name="iterateOverPluginParameters"/>
</xsl:template>

<xsl:template name="handlePluginParameter">
  $nodeIDs['<xsl:value-of select="current()"/>'] = array();
  $nodeIDs['<xsl:value-of select="current()"/>']['instanceNo'] = $instance;
  $nodeIDs['<xsl:value-of select="current()"/>']['symbol'] = "<xsl:value-of select="key('descriptionsByNodeID', current())/lv2:symbol"/>";
  $nodeIDs['<xsl:value-of select="current()"/>']['default'] = "<xsl:value-of select="key('descriptionsByNodeID', current())/lv2:default"/>";
  $nodeIDs['<xsl:value-of select="current()"/>']['value'] = $nodeIDs['<xsl:value-of select="current()"/>']['default']; 
</xsl:template>

</xsl:stylesheet>
