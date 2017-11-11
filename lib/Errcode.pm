package Errcode;
use strict;
use warnings;
use Data::Dumper ();
use Scalar::Util qw/blessed/;

our $VERSION = "0.01";

use overload (
    fallback => 1,
    '=='     => \&is,
    '!='     => \&isnt,
    'eq'     => \&is,
    'ne'     => \&isnt,
    q{""}    => \&message,
);

sub new {
    my ($class, $code, $message, $param) = @_;
    $param = {} unless defined $param;

    return bless {
        code    => $code,
        message => $message,
        param   => $param,
        frame   => [caller],
    }, $class;
}

sub _guess_code {
    my $err_or_code = shift;
    if (blessed($err_or_code) && $err_or_code->isa(__PACKAGE__)) {
        return $err_or_code->{code};
    }
    return $err_or_code;
}

sub is   { $_[0]->{code} eq _guess_code($_[1]) }
sub isnt { $_[0]->{code} ne _guess_code($_[1]) }

sub wrap {
    my ($self, $message, $param) = @_;
    $param = {} unless defined $param;

    return bless {
        code    => $self->{code},
        message => (defined $message ? $message : $self->{message}),
        param   => {%{$self->{param}}, %$param},
        frame   => [caller],
    }, ref $self;
}

sub _error_format {
    my $format = shift;
    my $param  = @_ == 1 && ref $_[0] eq 'HASH' ? $_[0] : {@_};

    my $rx; $rx = qr{
        { \s*
        (
            (?> [^\s{}]+ )
            | (??{ $rx })
        )+
        \s* }
    }x;
    $format =~ s{$rx}{
        if (!defined $param->{$1} || ref $param->{$1}) {
            Data::Dumper->new([$param->{$1}])->Terse(1)->Indent(0)->Sortkeys(1)->Dump
        } else {
            $param->{$1};
        }
    }eg;
    return $format;
}

sub message {
    my $self = shift;
    return undef unless defined $self->{message};
    return _error_format($self->{message}, $self->{param});
}

sub debug {
    my $self = shift;
    my ($package, $filename, $line) = @{$self->{frame}};
    return "at $filename line $line";
}

sub error { warn $_[0]->message . ' ' . $_[0]->debug . "\n" }
sub fatal { die  $_[0]->message . ' ' . $_[0]->debug . "\n" }

1;
__END__

=encoding utf-8

=head1 NAME

Errcode - Error object based on error code

=head1 SYNOPSIS

    use Errcode;

    my $err = Errcode->new('ERRCODE_XXX', 'error description: {a}', {a => 'argument'});
    if ($err == 'ERRCODE_XXX') {
        $err->error;
    } elsif ($err == 'ERRCODE_YYY') {
        $err->fatal;
    }

=head1 DESCRIPTION

Errcode is ...

=head1 METHODS

=over 4

=item my $err = Errcode->new($code, $message, $param);

=item my $ok = $err->is($err_or_code);

=item my $ok = $err->isnt($err_or_code);

=item my $wrapped_err = $err->wrap($message, $param);

=item my $message = $err->message;

=item my $debug = $err->debug;

=item $err->error;

=item $err->fatal;

=back

=head1 LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takumi Akiyama E<lt>t.akiym@gmail.comE<gt>

=cut
