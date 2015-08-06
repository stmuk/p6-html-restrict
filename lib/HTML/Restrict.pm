use v6;
use HTML::Parser::XML;

class HTML::Restrict {

    has $.html;
    our $i;

    constant DEBUG = %*ENV<DEBUG>;
    
    # list of permitted tags
    my @TAGS-OK = <a b br em hr i img p strong tt u>;

    # list of forbidden attributes and values
    my @BAD-THINGS = any(rx/onmouseover/, rx/javascript/);

    method restrict {
        my $html = $.html;
        # strip out PHP
        $html ~~ s:g/'<?php' .*? '?>'//;

        my $parser = HTML::Parser::XML.new;
        my XML::Document $doc = $parser.parse($html);

        DEBUG and warn $doc.gist;

        walk($doc);

        return $doc
    }

    sub walk($doc) {
        for $doc.elements -> $elem {

            if $elem.nodes {
                walk-nodes($elem.nodes);
            }

            clean($elem);
        }
    }

    sub walk-nodes(@nodes) {

        # this is recusive and needs a limit XXX
        $i++;
        die if $i == 100;

        for @nodes -> $elem {
            next if $elem.can('text'); # work around .WHAT issue XXX
            clean($elem) ;

            if $elem.nodes {
                walk-nodes($elem.nodes);
            }

        }

    }

    sub clean($elem) {

        DEBUG and say 'name: ' ~ $elem.name.gist;
        DEBUG and say ' attribs: ' ~ $elem.attribs.gist;

        $elem.remove unless $elem.name eq any @TAGS-OK; 

        if $elem.attribs.values.so {
            for $elem.attribs.kv -> $k, $v {
                if $k.lc ~~ any @BAD-THINGS or $v.lc ~~ any @BAD-THINGS {
                    DEBUG and say "nuking:" ~ $k;
                    $elem.unset($k);
                }

            }
        }

    }
}
