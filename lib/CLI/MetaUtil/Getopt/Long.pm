package CLI::MetaUtil::Getopt::Long;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;

use Getopt::Long ();

use Exporter qw(import);
our @EXPORT_OK = qw(GetOptionsCLIWrapper);
our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Routine related to Getopt::Long',
};

$SPEC{GetOptionsCLIWrapper} = {
    v => 1.1,
    summary => 'Get options for a CLI wrapper',
    description => <<'_',

This routine can be used to get options for your CLI wrapper. For example, if
you are creating a wrapper for the `diff` command, this routine will let you
collect all known `diff` options (declared in <pm:CLI::Meta::diff>) while
letting you add new options.

_
    args => {
        cli => {
            schema => 'str*',
            req => 1,
        },
        add_opts => {
            schema => 'hash*',
        },
    },
};
sub GetOptionsCLIWrapper {
    my %args = @_;
    my $cli = $args{cli};

    my %opts;
    my $mod = "CLI::Meta::$cli";
    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;
    my $meta = ${"$mod\::META"};

    my @cli_argv;
    my $code_push_opt     = sub { my ($cb, $optval) = @_; my $optname = $cb->name; push @cli_argv, (length($optname) > 1 ? "--" : "-").$optname };
    my $code_push_opt_val = sub { my ($cb, $optval) = @_; my $optname = $cb->name; push @cli_argv, (length($optname) > 1 ? "--" : "-").$optname, $optval };
    for my $optspec (keys %{ $meta->{opts} }) {
        $opts{$optspec} = $optspec =~ /=/ ? $code_push_opt_val : $code_push_opt;
    }
    if ($args{add_opts}) {
        for my $optname (keys %{ $args{add_opts} }) {
            $opts{$optname} = $args{add_opts}{$optname};
        }
    }

    Getopt::Long::GetOptions(%opts);
    @ARGV = @cli_argv;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

=cut
