use v6;
use HTML::Parser::XML;

constant DEBUG = %*ENV<DEBUG>;

class HTML::Restrict {

    has @.good-tags =  <a b br em hr i img p strong tt u>;
    has @.bad-attrib-vals = any(rx/onmouseover/, rx/javascript/);
    has $.recurse-depth = 100;

    my $recurse-count = 0;

    method process(:$html is copy) {

        # strip out PHP
        $html ~~ s:g/'<?php' .*? '?>'//;

        my $parser = HTML::Parser::XML.new;
        my XML::Document $doc = $parser.parse($html);

        DEBUG and warn $doc.gist;

        self.walk($doc);

        return $doc
    }

    method walk($doc) {
        for $doc.elements -> $elem {

            if $elem.nodes {
                self.walk-nodes($elem.nodes);
            }

            self.clean($elem);
        }
    }

    method walk-nodes(@nodes) {

        # this is recusive and needs a limit XXX
        $recurse-count++;
        die "recurse count reached" if $recurse-count == $.recurse-depth;

        for @nodes -> $elem {
            next if $elem.can('text'); # work around .WHAT issue XXX
            self.clean($elem) ;

            if $elem.nodes {
                self.walk-nodes($elem.nodes);
            }

        }

    }

    method clean($elem) {

        DEBUG and say 'name: ' ~ $elem.name.gist;
        DEBUG and say ' attribs: ' ~ $elem.attribs.gist;

        $elem.remove unless $elem.name eq any @.good-tags; 

        if $elem.attribs.values.so {
            for $elem.attribs.kv -> $k, $v {
                if $k.lc ~~ any @.bad-attrib-vals or $v.lc ~~ any @.bad-attrib-vals {
                    DEBUG and say "nuking:" ~ $k;
                    $elem.unset($k);
                }

            }
        }

    }
}
