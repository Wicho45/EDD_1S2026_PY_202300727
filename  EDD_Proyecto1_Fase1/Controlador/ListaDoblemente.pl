package Controlador:: ListaDoblemente;

use strict;
use warnings;

use Modelo::Nodo;
use constant Nodo => 'Modelo::Nodo';

sub new {
    my($class) = @_;
    my $self ={
        cabeza => undef,
        cola => undef
    };

    bless $self, $class;
    return $self;
}

sub is_empty{
    my ($self) = @_;
    return !defined($self->{cabeza}) ? 1:0;
}

sub insertar{
    my ($self, $data) = @_;

    my $nuevo_nodo = Nodo -> new($data);

    $nuevo_nodo -> set_next($self -> {cabeza});

    if(defined($self -> {cabeza})){
        $self -> {cabeza} -> set_prev($nuevo_nodo);
    }

    $self -> {cabeza} = $nuevo_nodo;

    if(!defined($self -> {cola})){
        $self -> {cola} = $nuevo_nodo;
    }
}

sub eliminar {
    my ($self, $data) = @_;

    if($self -> is_empty()){
        print "\n La lista se encuentra vacia\n";
        return;
    }

    if($self -> {cabeza} -> get_data() eq $data){
        if(defined($self -> {cabeza} -> get_next())){
            $self -> {cabeza} = $self -> {cabeza} -> get_next();
    }

}