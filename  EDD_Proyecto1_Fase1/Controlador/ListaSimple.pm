
package Controlador::ListaSimple;

use strict;
use warnings;

use Modelo::Nodo;
use constant Nodo => 'Modelo::Nodo';

sub new{
    my ($class) = @_;

    my $self = {
        head => undef,
    };

    bless $self, $class;
    return $self;
}

sub isEmpty{
    my ($self) = @_;
    return !defined ($self->{head})? 1 : 0;
}

sub insertar{
    my ($self, $data) = @_;

    my $nuevo_nodo = Nodo->new($data);

    $nuevo_nodo->set_next($self->{head});
    
    $self->{head} = $nuevo_nodo;
}

sub delete{
    my ($self, $data) = @_;
    
    if ($self->isEmpty()){
        print "Lista vacia, no hay nada que eliminar.";
        return;
    }

    if ($self->{head}->get_data() == $data){ 
        $self->{head} = $self->{head}->get_next();

        print "$data eliminado correctamente\n";
        return;
    }

    my $anterior = $self->{head};
    my $actual = $anterior->get_next();

    while (defined($actual)){
        if ($actual->get_data() eq $data){
            $anterior->set_next($actual->get_next());
            print "Dato eliminado: $data\n";
            return
        }

        $anterior = $actual;
        $actual = $actual->get_next();
    }

    print "Dato: $data, no se encuentra en la lista.\n"
}

sub imprimir {
    my ($self) = @_;

    if ($self->isEmpty()) {
        print "\nLista vacia(\n";
        return;
    }

    print "Lista: \n";
    my $current = $self->{head};

    while (defined($current)) {
        print $current->get_data();

        if (defined($current->get_next())){
            print " -> ";
        }
        $current = $current->get_next();
    }
}

1;