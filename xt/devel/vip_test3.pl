
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

#--------------------------------------------------------------------------------

use Test::Builder ;
my $test_interface = new Test::Builder ;

my $redefined_sub_output = '' ;
sub TestPrintError
{
use Carp qw(longmess) ;

$redefined_sub_output = "$_[1]\n" . longmess() ;
}

sub is_error_generated 
{
my ($description) = @_ ;

my $ok = $redefined_sub_output ne '' ? 1 : 0 ;
$redefined_sub_output = '' ;

$test_interface->ok($ok, $description) || $test_interface->diag("        Expected error output") ;
}

sub isnt_error_generated 
{
my ($description) = @_ ;

my $ok = $redefined_sub_output eq '' ? 1 : 0 ;
my $redefined_sub_output_copy = $redefined_sub_output  ;
$redefined_sub_output = '' ;

$test_interface->ok($ok, $description) || $test_interface->diag("        Got unexpected: '$redefined_sub_output_copy'.") ;
}

#--------------------------------------------------------------------------------

my $text = <<EOT ;
line 1 - 1
line 2 - 2 2
EOT

my $buffer = new Text::Editor::Vip::Buffer() ;
$buffer->ExpandWith('PrintError', \&TestPrintError) ;

$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::FindReplace') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Test') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::Selection') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::Clipboard') ;

$buffer->ExpandWith('AppendSelectionToClipboardContents') ;

# AppendSelectionToClipboardContents
$buffer->Reset() ;
$buffer->Insert($text) ;
$buffer->SetModificationPosition(0, 0) ;

$buffer->SetSelectionBoundaries(0, 1, 1, 2) ;
$buffer->AppendSelectionToClipboardContents('string') ;
is($buffer->GetClipboardContents('string'), "ine 1 - 1\nli", 'getting clipboard named with string and from selection') ;
$buffer->ClearClipboardContents('string') ;
is($buffer->GetClipboardContents('string'), '', 'getting clipboard named with string and from selection') ;

# select all
my $number_of_lines = $buffer->GetNumberOfLines() ;
my $buffer_text = $buffer->GetText() ;

$buffer->SelectAll() ;
$buffer->AppendSelectionToClipboardContents('string') ;
isnt_error_generated('AppendSelectionToClipboardContents generates no error') ;
is($buffer->GetClipboardContents('string'), $buffer_text, 'current line copied to clipboard') ;
is($buffer->GetNumberOfLines(), $number_of_lines, 'unmodified number of lines') ;
is($buffer->CompareText($buffer_text), '', "unmodified buffer contents") ;

#empty buffer, paste clipboard
$buffer->Delete() ;
$buffer->InsertClipboardContents('string') ;
is($buffer->GetClipboardContents('string'), $buffer_text, 'current line copied to clipboard') ;
is($buffer->GetNumberOfLines(), $number_of_lines, 'unmodified number of lines') ;
is($buffer->CompareText($buffer_text), '', "unmodified buffer contents") ;

# arg errors
$buffer->AppendSelectionToClipboardContents('string', 1, 2) ;
is_error_generated('wrong number of arguments generates error') ;
is($buffer->GetClipboardContents('string'), $text, 'clipboard unchanged') ;

$buffer->AppendSelectionToClipboardContents(undef) ;
is_error_generated('appending to undef clipboard generates error') ;

$buffer->AppendSelectionToClipboardContents('') ;
is_error_generated('appending empty clipboard name generates error') ;

$buffer->AppendSelectionToClipboardContents([]) ;
is_error_generated('appending array name generates error') ;

#~selection error
$buffer->Reset() ;
$buffer->Insert($text) ;

# no selection
$buffer->AppendSelectionToClipboardContents('string') ;
is_error_generated('AppendSelectionToClipboardContents with no selection generates error') ;
is($buffer->GetClipboardContents('string'), '', 'nothing copied to clipboard') ;

$buffer->ClearClipboardContents('string') ;
$buffer->SetSelectionBoundaries(-10, 0, 2, 0) ;
$buffer->CopySelectionToClipboard('string') ;
is($buffer->GetClipboardContents('string'), $text, 'getting clipboard named with string and from selection') ;
isnt_error_generated('selection is boxed') ;

$buffer->ClearClipboardContents('string') ;
$buffer->SetSelectionBoundaries(0, 0, 3, 0) ;
$buffer->CopySelectionToClipboard('string') ;
is($buffer->GetClipboardContents('string'), $text, 'getting clipboard named with string and from selection') ;
isnt_error_generated('selection is boxed') ;

#-------------------------------------------------------------------------------------------------------------

sub AppendSelectionToClipboardContents
{

=head2 AppendSelectionToClipboardContents

Adds the current selection to a clipboars

B<Arguments:>

=over 2

=item * clipboard name, a scalar

=back

  $buffer->AppendSelectionToClipboardContents(4, 'clipboard') ;

=cut

my ($buffer, $clipboard_name) = @_ ;

if('' ne ref $clipboard_name || ! defined $clipboard_name || '' eq $clipboard_name)
	{
	$buffer->PrintError("AppendSelectionToClipboardContents: Invalid clipboard name!") ;
	return(0) ;
	}
	
if(@_ != 2)
	{
	$buffer->PrintError("AppendSelectionToClipboardContents: wrong number of arguments!") ;
	return(0) ;
	}

unless($buffer->IsSelectionEmpty())
	{
	$buffer->AppendToClipboardContents($clipboard_name, $buffer->GetSelectionText()) ;
	}
else
	{
	$buffer->PrintError("AppendSelectionToClipboardContents: no selection!") ;
	}

return(1) ;
}

