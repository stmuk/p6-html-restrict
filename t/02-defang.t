use v6;
use Test; 
use HTML::Restrict;

plan 1;

my $html = q[
        <?php   echo(" EVIL EVIL EVIL "); ?>    <!-- asdf -->
            <A href="javascript:alert('die die die');">HREF=JAVA &lt;!&gt;</A>
        <hr>
        <I FAKE="attribute" > IN ITALICS WITH FAKE="attribute" </I><br>
        <B> IN BOLD </B><br>
            <A HREF="javascript:alert('die die die');">HREF=JAVA &lt;!&gt;</A>
        <A NAME="evil">
            <A HREF="javascript:alert('die die die');">HREF=JAVA &lt;!&gt;</A>
            <br>
            <A HREF="image/bigone.jpg" ONMOUSEOVER="alert('die die die');">
                <IMG SRC="image/smallone.jpg" ALT="ONMOUSEOVER JAVASCRIPT">
            </A>
        </A> <br>
];

my $hr = HTML::Restrict.new(:$html);

my $doc = $hr.restrict;

my $got = $doc.gist;

my $expected = "<?xml version=\"1.0\"?><html><!--asdf -->  <a>HREF=JAVA \&lt;!\&gt;</a>  <hr/>  <i FAKE=\"attribute\"> IN ITALICS WITH FAKE=\"attribute\" </i> <br/>  <b> IN BOLD </b> <br/>  <a>HREF=JAVA \&lt;!\&gt;</a>  <a NAME=\"evil\"> <a>HREF=JAVA \&lt;!\&gt;</a>  <br/>  <a HREF=\"image/bigone.jpg\"> <img SRC=\"image/smallone.jpg\"/>  </a>  </a>  <br/></html>";

ok $got eq $expected or die $got.gist;
