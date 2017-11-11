[![Build Status](https://travis-ci.org/akiym/Errcode.svg?branch=master)](https://travis-ci.org/akiym/Errcode)
# NAME

Errcode - Error object based on error code

# SYNOPSIS

    use Errcode;

    my $err = Errcode->new('ERRCODE_XXX', 'error description: {a}', {a => 'argument'});
    if ($err == 'ERRCODE_XXX') {
        $err->error;
    } elsif ($err == 'ERRCODE_YYY') {
        $err->fatal;
    }

# DESCRIPTION

Errcode is ...

# METHODS

- my $err = Errcode->new($code, $message, $param);
- my $ok = $err->is($err\_or\_code);
- my $ok = $err->isnt($err\_or\_code);
- my $wrapped\_err = $err->wrap($message, $param);
- my $message = $err->message;
- my $debug = $err->debug;
- $err->error;
- $err->fatal;

# LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Takumi Akiyama <t.akiym@gmail.com>
