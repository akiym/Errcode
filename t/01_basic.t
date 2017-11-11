use Test2::V0;
use Errcode;

subtest 'new' => sub {
    my $err = Errcode->new('A', 'description for error A', {a => 1, b => 2});
    is $err, object {
        prop blessed  => 'Errcode';
        field code    => 'A';
        field message => 'description for error A';
        field param   => {a => 1, b => 2};
        field frame   => ['main', match(qr!t/01_basic\.t$!), 5];
        end;
    };
};

subtest 'is' => sub {
    my $err = Errcode->new('A');

    ok($err->is($err));
    ok($err->is(Errcode->new('A')));
    ok($err->is('A'));

    subtest 'overload' => sub {
        ok($err == $err);
        ok($err == Errcode->new('A'));
        ok($err == 'A');
        ok($err eq $err);
        ok($err eq Errcode->new('A'));
        ok($err eq 'A');
    };
};

subtest 'isnt' => sub {
    my $err1 = Errcode->new('A');
    my $err2 = Errcode->new('B');

    ok($err1->isnt($err2));
    ok($err1->isnt(Errcode->new('B')));
    ok($err1->isnt('B'));

    subtest 'overload' => sub {
        ok($err1 != $err2);
        ok($err1 != Errcode->new('B'));
        ok($err1 != 'B');
        ok($err1 ne $err2);
        ok($err1 ne Errcode->new('B'));
        ok($err1 ne 'B');
    };
};

subtest 'wrap' => sub {
    my $err = Errcode->new('A', 'foo: {bar}', {bar => 'BAR'});
    is $err->wrap, object {
        prop blessed  => 'Errcode';
        field code    => 'A';
        field message => 'foo: {bar}';
        field param   => {bar => 'BAR'};
        field frame   => ['main', match(qr!t/01_basic\.t$!), 60];
        end;
    };
    is $err->wrap('baz: {bar}'), object {
        call message => 'baz: BAR';
        field frame  => ['main', match(qr!t/01_basic\.t$!), 65];
        etc;
    };
    is $err->wrap('baz: {bar}-{baz}', {bar => 'bar', baz => 'BAZ'}), object {
        call message => 'baz: bar-BAZ';
        field frame  => ['main', match(qr!t/01_basic\.t$!), 70];
        etc;
    };
};

subtest 'message' => sub {
    my $err = Errcode->new('A', 'foo: {bar}', {bar => 'BAR'});
    is $err->message, 'foo: BAR';

    subtest '_error_format' => sub {
        *_error_format = \&Errcode::_error_format;

        is _error_format(''), '';
        is _error_format('A'), 'A';

        is _error_format('{A}', A => 'A'), 'A';
        is _error_format('hello, {world}', world => '世界'), 'hello, 世界';
        is _error_format('hello, {world}{world}', world => '世界'), 'hello, 世界世界';
        is _error_format('{foo}'), 'undef';

        subtest 'reference' => sub {
            is _error_format('{a}', a => {foo => 1, bar => 2}), "{'bar' => 2,'foo' => 1}";
        };

        subtest 'empty' => sub {
            is _error_format('{}'), '{}';
            is _error_format('{ }'), '{ }';
            is _error_format('{{}}'), '{{}}';
        };

        subtest 'nested' => sub {
            is _error_format('{{a}}', a => 1), 'undef';
            is _error_format('{{a}}', '{a}' => 1), '1';
            is _error_format('{{ a }}', '{ a }' => 1), '1';
        };
    };
};

subtest 'debug' => sub {
    my $err = Errcode->new('A', 'foo: {bar}', {bar => 'BAR'});
    like $err->debug, qr!^at .+t/01_basic\.t line 107$!;
};

subtest 'error' => sub {
    my $err = Errcode->new('A', 'foo');
    like warning {
        $err->error;
    }, qr!^foo at .+t/01_basic\.t line 112$!;
};

subtest 'fatal' => sub {
    my $err = Errcode->new('A', 'foo');
    like dies {
        $err->fatal;
    }, qr!^foo at .+t/01_basic\.t line 119$!;
};

done_testing;
