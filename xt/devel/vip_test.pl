# -*- perl -*-

# t/002_load.t - check module loading and create testing directory
# proudly stole some tests from Text::Buffer

use Data::TreeDumper ;
use Data::Hexdumper ;
use Text::Diff ;

use strict ;
my ($text, $expected_text) = ('', undef) ;

use Test::More qw(no_plan) ;
use Test::Exception ;
use Test::Differences ;
use Test::Warn ;

use Text::Editor::Vip::Buffer ;
use Text::Editor::Vip::Buffer::Test ;

#------------------------------------------------------------------------------------------------- 
$text = <<EOT ;
 line 1 - 1
  line 2 - 2 2
   line 3 - 3 3 3
    line 4 - 4 4 4 4
     line 5 - 5 5 5 5 5

something
EOT

my $buffer = new Text::Editor::Vip::Buffer() ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::FindReplace') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Test') ;
$buffer->Insert($text) ;

$buffer->SetModificationPosition(0, 0) ;
my @boundaries = (2, 4, 5, 6) ;

{
my $warning ;
local $SIG{'__WARN__'} = sub {$warning =  $_[0] ;} ;

$buffer->SetSelectionBoundaries(@boundaries) ;
$buffer->SetModificationPosition(7, 0) ;
is_deeply([$buffer->ReplaceOccurenceWithinBoundaries('3', '$2', @boundaries)], [2, 8, '3', ''], 'match outside boundaries') ;
warning_like {$buffer->ReplaceOccurenceWithinBoundaries('3', '$2', @boundaries)} qr'Use of uninitialized value in substitution iterator', 'invalid replacement warning' ;
}
