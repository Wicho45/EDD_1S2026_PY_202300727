package Controlador::ListaCircular;

use strict;
use warnings;

use Modelo::Nodo;
use constant Nodo => "Modelo::Nodo";

sub new{
    my ($class) = @_;
    my $self = {
        cabeza => undef,
    };
    bless $self, $class;
    return $self;
}

sub is_empty{
    my ($self) = @_;
    return !defined($self -> {cabeza}) ? 1:0;
}

sub insertar{
    my ($self, $data) = @_;

    my $nuevo_nodo = Nodo -> new($data);

    if (!defined($self -> {cabeza})){
        $self -> {cabeza} = $nuevo_nodo;
        $nuevo_nodo -> set_next($self -> {cabeza});
    } else {
        my $actual = $self -> {cabeza};
        while ($actual -> get_next() != $self -> {cabeza}){
            $actual = $actual -> get_next();
        }
        $actual -> set_next($nuevo_nodo);
        $nuevo_nodo -> set_next($self -> {cabeza});
    }
}

sub eliminar{
    my ($self, $data) = @_;

    #la lista esta vacia
    if ($self -> is_empty()){
        print "\n La lista se encuentra vacia\n";
        return;
    }

    my $actual = undef;

    #eliminar cabeza
    if ($self -> {cabeza} -> get_data() eq $data){
        $actual = $self -> {cabeza};
        while ($actual -> get_next() != $self -> {cabeza}){
            $actual = $actual -> get_next();
        }
        if ($self -> {cabeza} -> get_next() == $self -> {cabeza}){
            $self -> {cabeza} = undef;
        } else {
            $actual -> set_next($self -> {cabeza} -> get_next());
            $self -> {cabeza} = $self -> {cabeza} -> get_next();
        }
    } else {

    }
}

sub imprimir{
    my ($self) = @_;

    if ($self -> is_empty()){
        print "\n La lista esta vacia\n";
        return;
    }

    my $actual = $self->{cabeza};
    print "Contenido: ";
    do {
        print $actual->get_data() . " -> ";
        $actual = $actual->get_next();
    } while ($actual != $self->{cabeza});
    print "(vuelta a cabeza)\n";
}