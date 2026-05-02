package Backend::Controlador::listaDoblemente;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use Backend::Modelo::Nodo;
use constant Nodo => 'Backend::Modelo::Nodo';

sub new {
    my($class) = @_;
    my $self ={
        cabeza => undef,
        cola => undef
    };

    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined($self->{cabeza}) ? 1:0;
}

sub insertar {
    my ($self, $nuevo_med) = @_;
    my $nuevo_cod = $nuevo_med->get_codigo_medicamento();

    if ($self->is_empty()) {
        my $nuevo_nodo = Nodo->new($nuevo_med);
        $self->{cabeza} = $nuevo_nodo;
        $self->{cola}   = $nuevo_nodo;
        return "Primer medicamento registrado: $nuevo_cod";
    }

    my $actual = $self->{cabeza};
    while (defined($actual)) {
        my $med_en_lista = $actual->get_data();
        
        if ($med_en_lista->get_codigo_medicamento() eq $nuevo_cod) {
            if ($med_en_lista->es_identico($nuevo_med)) {
                return "Omitido: El medicamento con código $nuevo_cod ya existe con los mismos datos.";
            } 
            else {
                my ($numero) = $self->{cola}->get_data()->get_codigo_medicamento() =~ /(\d+)/;
                
                my $nuevo_codigo_generado = sprintf("MED%03d", ($numero || 0) + 1);
                $nuevo_med->set_codigo_medicamento($nuevo_codigo_generado);
                return $self->insertar($nuevo_med);
            }
        }
        $actual = $actual->get_next();
    }

    $actual = $self->{cabeza};
    $nuevo_cod = $nuevo_med->get_codigo_medicamento();

    if ($nuevo_cod lt $actual->get_data()->get_codigo_medicamento()) {
        my $nuevo_nodo = Nodo->new($nuevo_med);
        $nuevo_nodo->set_next($self->{cabeza});
        $self->{cabeza}->set_prev($nuevo_nodo);
        $self->{cabeza} = $nuevo_nodo;
        return "Insertado al inicio: $nuevo_cod";
    }

    while (defined($actual->get_next()) &&
        $actual->get_next()->get_data()->get_codigo_medicamento() lt $nuevo_cod) {
        $actual = $actual->get_next();
    }

    if (!defined($actual->get_next())) {
        $self->agregar_final($nuevo_med);
        return "Agregado al final: $nuevo_cod";
    } 
    else {
        my $nuevo_nodo = Nodo->new($nuevo_med);
        my $siguiente = $actual->get_next();

        $nuevo_nodo->set_next($siguiente);
        $nuevo_nodo->set_prev($actual);
        
        $siguiente->set_prev($nuevo_nodo);
        $actual->set_next($nuevo_nodo);
        
        return "Insertado ordenadamente: $nuevo_cod";
    }
}

sub eliminar {
    my ($self, $codigo) = @_; 

    return if $self->is_empty();

    my $actual = $self->{cabeza};

    while (defined($actual)) {
        if ($actual->get_data()->get_codigo_medicamento() eq $codigo) {
            
            if ($actual == $self->{cabeza} && $actual == $self->{cola}) {
                $self->{cabeza} = undef;
                $self->{cola} = undef;
            }
            elsif ($actual == $self->{cabeza}) {
                $self->{cabeza} = $actual->get_next();
                $self->{cabeza}->set_prev(undef) if defined($self->{cabeza});
            } 
            elsif ($actual == $self->{cola}) {
                $self->{cola} = $actual->get_prev();
                $self->{cola}->set_next(undef) if defined($self->{cola});
            }
            else {
                $actual->get_prev()->set_next($actual->get_next());
                $actual->get_next()->set_prev($actual->get_prev());
            }

            print "\nMedicamento $codigo eliminado.\n";
            return;
        }
        $actual = $actual->get_next();
    }
}

sub agregar_final {
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

sub imprimir {
    my ($self) = @_;

    if($self -> is_empty()){
        print "\n La lista esta vacia\n";
        return;
    }

    print "\n Imprimprimiendo lista: \n";

    my $actual = $self -> {cabeza};

    while(defined($actual)){
        my $m = $actual->get_data();
        print "\nCodigo: " . $m -> get_codigo_medicamento() . "\n";
        print "Nombre comercial: " . $m -> get_nombre_comercial() . "\n";
        print "Principio activo: " . $m -> get_principio_activo() . "\n";
        print "Laboratorio: " . $m -> get_laboratorio_fabricante() . "\n";
        print "Stock: " . $m -> get_stock() . "\n";
        print "Vencimiento: " . $m -> get_vencimiento() . "\n";
        print "Precio: " . $m -> get_precio() . "\n";
        print "Nivel reorden: " . $m -> get_nivel_reorden() . "\n";
        print "\n";
        
        $actual = $actual -> get_next();
    }
}

sub buscar {
    my ($self, $codigo) =@_;

    my $actual = $self -> {cabeza};

    while(defined($actual)){
        if($actual -> get_data() -> get_codigo_medicamento() eq $codigo){
            return 1;
        }
        $actual = $actual -> get_next();
    }

    return 0;
}

sub tamanio {
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