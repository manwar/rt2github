package Perl::RT2Github;
use 5.14.0;
use warnings;
our $VERSION     = '0.01';
use Carp;
use LWP::UserAgent;

sub new {
    my ($class) = @_;

    my %data = (
        rt_stem => 'https://rt.perl.org/Ticket/Display.html?id=',
        gh_stem => 'https://github.com/perl/perl5/issues/',
        field => 'location',
        results => {},
    );
    my $self = bless \%data, $class;
    return $self;
}

sub get_github_url {
    my ($self, $rt) = @_;
    croak "RT IDs were numeric" unless $rt =~ m/^\d+$/;
    my $rt_url = $self->{rt_stem} . $rt;

    my $ua = LWP::UserAgent->new(timeout => 10);
    my $response = $ua->head($rt_url);
    my $location = $response->previous->header($self->{field});
    if ($location =~ m{^$self->{gh_stem}\d+$}) {
        $self->{results}->{$rt}->{github_url} = $location;
    }
    else {
        $self->{results}->{$rt}->{github_url} = undef;
    };
    return $self->{results}->{$rt}->{github_url};
}

sub get_github_urls {
#    my ($self, $rt_ids_ref) = @_;
#    for my $rt (@{$rt_ids_ref}) {
    my ($self, @rt_ids) = @_;
    my %urls = ();
    for my $rt (@rt_ids) {
        my $gh_url = $self->get_github_url($rt);
        $urls{$rt} = $gh_url;
    }
    return \%urls;
}

sub get_github_id {
    my ($self, $rt) = @_;
    croak "RT IDs were numeric" unless $rt =~ m/^\d+$/;
    my $gh_url = $self->get_github_url($rt);
    my $gh_id;
    if (defined $gh_url) {
        ($gh_id) = $gh_url =~ m{^.*/(.*)$};
        $self->{results}->{$rt}->{github_id} = $gh_id;
    }
    else {
        $self->{results}->{$rt}->{github_id} = undef;
    }
    return $self->{results}->{$rt}->{github_id};
}

sub get_github_ids {
    my ($self, @rt_ids) = @_;
    my %ids = ();
    for my $rt (@rt_ids) {
        my $gh_id = $self->get_github_id($rt);
        if (defined $gh_id) {
            $self->{results}->{$rt}->{github_id} = $gh_id;
        }
        else {
            $self->{results}->{$rt}->{github_id} = undef;
        }
        $ids{$rt} = $gh_id;
    }
    return \%ids;
}

1;

=head1 NAME

Perl::RT2Github - Given RT ticket number, find corresponding Github issue

=head1 SYNOPSIS

    use Perl::RT2Github;

    my $self = Perl::RT2Github->new( 12345, 67890 );
    my $github_urls_ref = $self->get_github_urls();

=head1 DESCRIPTION

With the recent move of Perl 5 issue tracking from rt.cpan.org to github.com,
we need to be able to take a list of RT ticket numbers and look up the
corresponding github issue IDs and URLs.  This module is a first attempt at
doing so.

=head1 USAGE

TK

=head1 BUGS


TK


=head1 SUPPORT


TK


=head1 AUTHOR

    James E Keenan
    CPAN ID: JKEENAN
    jkeenan@cpan.org
    http://thenceforward.net/perl

=head1 ACKNOWLEDGMENTS

One implementation suggested by ilmari.

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).

=cut

