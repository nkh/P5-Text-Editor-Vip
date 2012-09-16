
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
EOT

my $redefined_sub_output = '' ;

use Test::Builder ;
my $test_interface = new Test::Builder ;

sub is_error_generated 
{
my ($description) = @_ ;

my $ok = $redefined_sub_output ne '' ? 1 : 0 ;
$redefined_sub_output = '' ;

$test_interface->ok($ok, $description) ;
$test_interface->diag("        Expected error output") ;
}

my $buffer = new Text::Editor::Vip::Buffer() ;
$buffer->ExpandWith('PrintError', sub {$redefined_sub_output = $_[1]}) ;

$buffer->ExpandWith('GenerateError', sub{$_[0]->PrintError("some error")}) ;
$buffer->ExpandWith('DoNotGenerateError', sub{}) ;

$buffer->GenerateError() ;
is_error_generated("error is generated") ;

$buffer->DoNotGenerateError() ;
is_error_generated("error is generated") ;
