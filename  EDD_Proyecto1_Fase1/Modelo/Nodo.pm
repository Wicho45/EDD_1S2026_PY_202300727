package Modelo::Nodo;

use strict;
use warnings;

sub new {
    my($class, $data) = @_;
    my $self ={
        data => $data,
        next => undef,
        prev => undef,
    };
    bless $self, $class;\
    return $self;
}

sub set_data{
    my ($self, $data) = @_;
    $self->{data} = $data;
}

sub get_data{
    return $_[0]->{data};
}

sub set_next{
    my ($self, $next_node) = @_;
    $self->{next} = $next_node;
}

sub get_next{
    return $_[0]->{next};
}

sub set_prev{
    my ($self, $prev_nodo) = @_;
    $self->{prev} = $prev_nodo;
}

sub get_prev{
    return $_[0]->{prev};
}

1;