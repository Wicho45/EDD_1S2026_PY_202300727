package Backend::Modelo::Nodo;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;

    my $self = {
        data  => $data,
        next  => undef,
        prev  => undef,
        left  => undef, 
        right => undef,
        altura => 0
    };

    bless $self, $class;
    return $self;
}

# Setters y getters
sub get_data {
    return $_[0]->{data};
}
sub set_data {
    my ($self, $new_data) = @_;
    $self->{data} = $new_data;
}

sub get_left {
    return $_[0]->{left};
}
sub set_left {
    my ($self, $nodo_izq) = @_;
    $self->{left} = $nodo_izq;
}

sub get_right {
    return $_[0]->{right};
}
sub set_right {
    my ($self, $nodo_der) = @_;
    $self->{right} = $nodo_der;
}

sub get_altura {
    return $_[0]->{altura};
}
sub set_altura {
    my ($self, $nueva_altura) = @_;
    $self->{altura} = $nueva_altura;
}

sub get_next {
    return $_[0]->{next};
}
sub set_next {
    my ($self, $next_node) = @_;
    $self->{next} = $next_node;
}

sub get_prev {
    return $_[0]->{prev};
}
sub set_prev {
    my ($self, $prev_node) = @_;
    $self->{prev} = $prev_node;
}

sub es_hoja {
    my ($self) = @_;
    return (!defined($self->{left}) && !defined($self->{right})) ? 1 : 0;
}

sub to_string {
    my ($self) = @_;
    my $data       = $self->{data};
    my $tiene_izq  = defined($self->{left})  ? "Si" : "No";
    my $tiene_der  = defined($self->{right}) ? "Si" : "No";
    return "Nodo[data=$data, hijo_izq=$tiene_izq, hijo_der=$tiene_der]\n";
}

sub imprimir_nodo {
    my ($self) = @_;
    print "Dato: $self->{data}\n";
    print "Hijo izquierdo: " . (defined($self->{left})  ? "si :) " : "no :(") . "\n";
    print "Hijo derecho:   " . (defined($self->{right}) ? "Si :)" : "No :(") . "\n\n";
}

1;