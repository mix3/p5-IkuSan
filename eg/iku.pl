#!/usr/bin/env perl
use 5.010;
use warnings;
use utf8;
use Encode qw/encode_utf8/;

use IkuSan;
use Data::Validator;
use Try::Tiny;

my $ikusan = IkuSan->new(
    host          => 'example.com',
    password      => '******',
    enable_ssl    => 1,
    join_channels => [qw/test/],
    max_workers   => 3,
#   respond_all   => 1,
    on_option_error => sub {
        my ($e, $receive) = @_;
        warn "on_option_error: $e";
        $receive->privmsg($receive->{from_nickname}.": およよ… $e");
    },
    on_error => sub {
        my ($e, $pm, $receive, $sub, $message, @matches) = @_;
        warn "on_error: $e";
        $receive->privmsg($receive->{from_nickname}.": およよ… $e");
    },
);

$ikusan->on_option(
    sleep => [qw/
        time|t=i
        die|d
    /] => sub {
        my ($pm, $receive, %args) = @_;
        state $validator = Data::Validator->new(
            time => { isa => "Int"                },
            die  => { isa => "Bool", default => 0 },
        );
        my $args = $validator->validate(%args) or die "validation error";
        $receive->privmsg($receive->{from_nickname}.": 寝ます");
        for my $c (1..$args->{time}) {
            sleep 1;
            $receive->notice("zzz…(".$c.")");
        }
        die if $args->{die};
        $receive->privmsg($receive->{from_nickname}.": 起きました");
    },
);

$ikusan->on_command(
    echo => sub {
        my ($pm, $receive, @args) = @_;
        $receive->privmsg($receive->{from_nickname}.": ".join(" ", @args));
    },
);

$ikusan->on_message(
    qr/^iku:?/ => sub {
        my ($pm, $receive) = @_;
        $receive->privmsg($receive->{from_nickname}.": ｻﾀﾃﾞｰﾅｲﾄﾌｨｰﾊﾞｰ!");
    },
);

$ikusan->run;
