# lv2rdf2html
(C) 2017-2018 by Jörn Nettingsmeier. This transform and all helper scripts and
code is licensed under the BSD 3-Clause license.

lv2rdf2html automatically generates HTML/jQuery GUIs for LV2 audio
plugins. The original usecase is to control plugin instances running
on embedded systems in a [mod-host](
https://github.com/moddevices/mod-host), but it can be adapted to
other uses easily.

The conversion is done with XSL transformations. This means that the 
LV2 metadata must be converted to XML first.

![UI generated for x42-fil#stereo (by Robin Gareus, DSP by Fons
!Adriaensen)](fil4stereo.png)
## Usage

### Automatic processing with generate.sh
The [make.sh](make.sh) script operates on a mod-host command history, and
automatically generates and deploys all required components. To use it, please edit the settings in
[lv2rdf.conf](lv2rdf.conf).

The generator script will then
* Collect the desired plugin documentation in temporary Turtle files using lv2info
* Convert the turtle files to a temporary RDF/XML file using [rapper](http://librdf.org/raptor/rapper.html)
(part of raptor/Redland, this is what I use for testing). 
* Tag all generated identifiers in the RDF/XML with their plugin ID no. to
make them globally unique
* Generate and prettyprint an XHTML user interface file
* Generate corresponding Javascript and CSS files
* Generate the server-side PHP AJAX handler
* optionally deploy them to the web server root

## Requirements

* LV2 plugins installed on your system,
* the LV2 tools lv2ls and lv2info,
* an XSLT 1.0  processor such as 
  * xsltproc or 
  * saxon (currently unsupported unless you process manually),
* a Turtle-to-XML RDF converter, such as
  * [rapper](http://librdf.org/raptor/rapper.html) or
  * [rdf2rdf](http://www.l3s.de/~minack/rdf2rdf/) (currently unsupported
    unless you process manually),
* [mod-host](https://github.com/moddevices/mod-host), and
* a PHP-capable webserver

## Status

lv2rdf2html currently supports all LV2 features used by the plugins
listed above. As bugs are shaken out, more plugins will be added to the 
testing environment. 
The generated web GUI is fully functional and interacts with a configurable
mod-host instance, with a few missing features listed in the [TODO](TODO.md) 
file that do not impede basic usability. 
    
## Notes

Rdf2rdf and rapper produce different RDF/XML: rdf2rdf tries to collate
triplets (but does a horrible job of doing it in a consistent way), and rapper
does the simple, clean thing of keeping every single triplet separate. Both work
because the stylesheet doesn't make any assumptions about them being grouped, 
that's why it's soo terrible.
  
There is a very clean alternative converter at http://www.easyrdf.org/converter
which appears to do perfect grouping, but I'm a bit wary of supporting it because
it requires PHP, fails to include namespace prefixes and seems to make a few risky guesses...

Sometimes, the generated UI is not very nice to use because of deficiencies
in this code, and sometimes because the plugin's metadata is sub-optimal.
Calf is a bad example here, it does much usability magic in its GUI and
exposes ports with coefficient gains rather than logarithmic. I hope I can
get a few of these issues fixed upstream as the project matures.
