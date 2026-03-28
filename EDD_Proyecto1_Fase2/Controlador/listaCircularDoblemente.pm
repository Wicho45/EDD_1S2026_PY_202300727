package Controlador::listaCircularDoblemente;

use strict;
use warnings;

use Modelo::Nodo;
use constant Nodo => 'Modelo::Nodo';

sub new {
    my ($class) = @_;
    my $self = { cabeza => undef };
    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined($self->{cabeza});
}

sub insertar {
    my ($self, $data) = @_;
    my $nuevo = Modelo::Nodo->new($data);

    if ($self->is_empty()) {

        $self->{cabeza} = $nuevo;
        $nuevo->set_next($nuevo);
        $nuevo->set_prev($nuevo);
    } else {
        my $cabeza = $self->{cabeza};
        my $ultimo = $cabeza->get_prev();

        $nuevo->set_next($cabeza);
        $nuevo->set_prev($ultimo);
        
        $ultimo->set_next($nuevo);
        $cabeza->set_prev($nuevo);
    }
}

sub eliminar {
    my ($self, $data) = @_;

    if ($self->is_empty()) {
        print "\nLa lista está vacía, nada que eliminar.\n";
        return;
    }

    my $actual = $self->{cabeza};
    my $encontrado = 0;

    do {
        if ($actual->get_data() == $data) {
            $encontrado = 1;
            last;
        }
        $actual = $actual->get_next();
    } while ($actual != $self->{cabeza});

    if ($encontrado) {

        if ($actual->get_next() == $actual) {
            $self->{cabeza} = undef;
        } 
        else {

            my $anterior = $actual->get_prev();
            my $siguiente = $actual->get_next();

            $anterior->set_next($siguiente);
            $siguiente->set_prev($anterior);

            if ($actual == $self->{cabeza}) {
                $self->{cabeza} = $siguiente;
            }
        }
        print "\nDato '$data' eliminado correctamente.\n";
    } else {
        print "\nEl dato '$data' no se encuentra en la lista.\n";
    }
}

sub imprimir {
    my ($self) = @_;
    return print "Lista vacía\n" if $self->is_empty();

    my $actual = $self->{cabeza};
    print "Lista Circular Doble: ";
    do {
        print $actual->get_data() . " <-> ";
        $actual = $actual->get_next();
    } while ($actual != $self->{cabeza});
    print "(regresa al inicio)\n";
}

1;