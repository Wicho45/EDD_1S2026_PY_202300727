package Controlador::ListaDoblemente;

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

#lista vacia
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

    #la lista esta vacia
    if($self -> is_empty()){
        print "\n La lista se encuentra vacia\n";
        return;
    }

    #eliminar cabeza
    if($self -> {cabeza} -> get_data() eq $data){

        if(defined($self -> {cabeza} -> get_next())){
            $self -> {cabeza} = $self -> {cabeza} -> get_next();
        }

        $self -> {cabeza} =  $self -> {cabeza} -> get_next();

        if(!defined($self -> {cabeza})){
            $self -> {cola} = undef;
        }

        print "\n Nodo eliminado con exito (cabeza) \n ";
        return;
    }

    #eliminar al medio 

    my $actual = $self -> {cabeza} -> get_next();

    while(defined($actual)){
        if($actual -> get_data() eq $data){

            if(defined($actual -> get_next())){
                $actual -> get_prev() -> set_prev($actual -> get_prev());
            } else {
                $self -> {cola} = $actual -> get_prev();
            }

            if(defined($actual -> get_prev())){
                $actual -> get_prev() -> set_next($actual -> get_next());
            }

            print "\n Nodo eliminado con exito (medio) \n ";
            return;
        }

        $actual = $actual -> get_next();

    }
}

sub agregar_final{
    my ($self , $data) = @_;

    my $nuevo_nodo = Nodo -> new($data);

    if($self -> is_empty()){
    
        $self -> {cabeza} = $nuevo_nodo;
        $self -> {cola} = $nuevo_nodo;
        return;
    
    }

    $nuevo_nodo -> set_prev($self -> {cola});
    $self -> {cola} -> set_next($nuevo_nodo);
    $self -> {cola} = $nuevo_nodo;

}

sub imprimir{

    my ($self) = @_;

    #lista vacia
    if($self -> is_empty()){
        print "\n La lista esta vacia\n";
        return;
    }

    print "\n Imprimprimiendo lista: \n";

    my $actual = $self -> {cabeza};

    while(defined($actual)){

        print $actual -> get_data() ;

        if(defined($actual -> get_next())){
            print " <-> ";
        }
        $actual = $actual -> get_next();
    }

}

sub buscar{
    my ($self, $data) =@_;

    my $actual = $self -> {cabeza};

    while(defines($actual)){
        if($actual -> get_data() eq $data){
            return 1;
        }
        $actual = $actual -> get_next();
    }

    return 0;

}

sub lenth{
    my ($self) = @_;

    my $contador = 0;
    my $actual = $self -> {cabeza};

    while(defined($actual)){
        $contador++;
        $actual = $actual -> get_next();
    }
    return $contador;
}

1;