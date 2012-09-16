
use strict ;
use warnings ;

#~ use Devel::SimpleTrace ;
#~ use Carp::Indeed ;

use lib qw(lib) ;

use Data::TreeDumper ;
use Data::Hexdumper ;
use Text::Diff ;

use Test::More qw(no_plan);
use Test::Differences ;
use Test::Exception ;

use Text::Editor::Vip::Buffer ;
use Text::Editor::Vip::Buffer::Test ;

my $text = <<EOT ;
line 1 - 1
line 2 - 2 2
line 3 - 3 3 3
line 4 - 4 4 4 4
line 5 - 5 5 5 5 5
EOT

my $expected_text  ;

my $buffer = new Text::Editor::Vip::Buffer() ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::FindReplace') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Test') ;

$buffer->Insert("0") ;
#~ is($buffer->GetText(), "0", "inserting 0") ;

#~ my @text_to_insert = ("0") ;

#~ for(@text_to_insert)
	#~ {
	#~ for(split /(\n)/) # transform a\nb\nccc into 3 lines
		#~ {
		#~ if("\n" eq $_)
			#~ {
			#~ print "new line\n" ;
			#~ }
		#~ else
			#~ {
			#~ # insert characters
			#~ print "$_\n" ;
				
			#~ print "length = " . length() . "\n" ;
			#~ }
		#~ }
	#~ }

SplitOnNewline("\n") ;
SplitOnNewline('0') ;
SplitOnNewline("0\n") ;
SplitOnNewline("0\n1") ;
SplitOnNewline("0\n1\n") ;
SplitOnNewline("0\n1\n2") ;
SplitOnNewline("0\n1\n2\n") ;

sub SplitOnNewline
{
my ($text) = @_ ;

print "--------Split-----------\n" ;
print "$text\n" ;
print "------------------------\n" ;

my @elements = split(/(\n)/, $text) ;

print scalar(@elements) . " elements\n" ;

while(my ($element, $nl) = splice(@elements, 0, 2))
	{
	if($nl)
		{
		print "=> >$element<\n" ;
		}
	else
		{
		print ">$element<\n" ;
		}
	}

print "------------------------\n\n" ;
}

