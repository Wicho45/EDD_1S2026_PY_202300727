package Backend::Controlador::bst;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use Backend::Modelo::Nodo;
use constant Nodo => 'Backend::Modelo::Nodo';

sub new {
    my ($class) = @_;

    my $self = {
        root => undef,
        size => 0, 
    };

    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined($self->{root}) ? 1 : 0;
}

sub get_size {
    my ($self) = @_;
    return $self->{size};
}

sub insertar {
    my ($self, $equipo_obj) = @_;
    my $data = $equipo_obj->get_codigo();

    if (!defined($self->{root})) {
        $self->{root} = Nodo->new($equipo_obj);
        $self->{size}++;
        print " -----> Insertado '$data' como ROOT del arbol.\n";
        return;
    }

    my $insertado = $self->_insertar_recursivo($self->{root}, $equipo_obj);

    if ($insertado) {
        $self->{size}++;
    }
}

sub _insertar_recursivo {
    my ($self, $nodo_actual, $equipo_obj) = @_;

    my $data = $equipo_obj->get_codigo();
    my $valor_actual = $nodo_actual->get_data()->get_codigo();

    if ($data lt $valor_actual) {

        if (!defined($nodo_actual->get_left())) {
            $nodo_actual->set_left(Nodo->new($equipo_obj));
            print "Insertado '$data' a la IZQUIERDA de '$valor_actual'.\n";
            return 1;
        } else {
            return $self->_insertar_recursivo($nodo_actual->get_left(), $equipo_obj);
        }
    }

    elsif ($data gt $valor_actual) {

        if (!defined($nodo_actual->get_right())) {
            $nodo_actual->set_right(Nodo->new($equipo_obj));
            print "Insertado '$data' a la DERECHA de '$valor_actual'.\n";
            return 1;
        } else {
            return $self->_insertar_recursivo($nodo_actual->get_right(), $equipo_obj);
        }
    }

    else {
        print "ERRRO: El valor '$data' ya existe en el arbol. No se insertaron duplicados.\n";
        return 0;
    }
}

sub buscar {
    my ($self, $codigo) = @_;

    if ($self->is_empty()) {
        print "El arbol está vacio. No hay nada que buscar.\n";
        return undef;
    }
    return $self->_buscar_recursivo($self->{root}, $codigo);
}

sub _buscar_recursivo {
    my ($self, $nodo_actual, $codigo) = @_;

    if (!defined($nodo_actual)) {
        return undef;
    }

    my $valor_actual = $nodo_actual->get_data()->get_codigo();

    if ($codigo eq $valor_actual) {
        return $nodo_actual;
    }
    elsif ($codigo lt $valor_actual) {
        return $self->_buscar_recursivo($nodo_actual->get_left(), $codigo);
    }

    else {
        return $self->_buscar_recursivo($nodo_actual->get_right(), $codigo);
    }
}


sub eliminar {
    my ($self, $codigo) = @_;

    if ($self->is_empty()) {
        print "El arbol está vacio. No hay nada que eliminar.\n";
        return;
    }

    my $existe = $self->buscar($codigo);
    if (!defined($existe)) {
        print "El valor '$codigo' no existe en el arbol.\n";
        return;
    }

    $self->{root} = $self->_eliminar_recursivo($self->{root}, $codigo);
    $self->{size}--;
    print "Valor '$codigo' eliminado exitosamente.\n";
}


sub _eliminar_recursivo {
    my ($self, $nodo_actual, $codigo) = @_;

    if (!defined($nodo_actual)) {
        return undef;
    }

    my $valor_actual = $nodo_actual->get_data()->get_codigo();

    if ($codigo lt $valor_actual) {
        $nodo_actual->set_left(
            $self->_eliminar_recursivo($nodo_actual->get_left(), $codigo)
        );
        return $nodo_actual;

    } elsif ($codigo gt $valor_actual) {
        $nodo_actual->set_right(
            $self->_eliminar_recursivo($nodo_actual->get_right(), $codigo)
        );
        return $nodo_actual;

    } else {
        if ($nodo_actual->es_hoja()) {
            print "Eliminando hoja con valor '$valor_actual'.\n";
            return undef;  
        }

        elsif (!defined($nodo_actual->get_left())) {
            print "Eliminando nodo '$valor_actual' (solo tiene hijo derecho).\n";
            return $nodo_actual->get_right();  
        }

        elsif (!defined($nodo_actual->get_right())) {
            print "Eliminando nodo '$valor_actual' (solo tiene hijo izquierdo).\n";
            return $nodo_actual->get_left(); 
        }
        
        else {
            print "Eliminando nodo '$valor_actual' (tiene dos hijos).\n";
            print "Buscando sucesor inorden en el subarbol derecho, o sea izquierda -> root -> derecha (ver pizarron si hay confusión aun en esto)...\n";

            my $sucesor = $self->_encontrar_minimo($nodo_actual->get_right());
            my $equipo_sucesor = $sucesor->get_data();

            print "Sucesor inorden encontrado: '" . $equipo_sucesor->get_codigo() . "'. Reemplazando...\n";

            $nodo_actual->set_data($equipo_sucesor);
            $nodo_actual->set_right(
                $self->_eliminar_recursivo($nodo_actual->get_right(), $equipo_sucesor->get_codigo())
            );

            return $nodo_actual;  
        }
    }
}


sub _encontrar_minimo {
    my ($self, $nodo) = @_;

    if (!defined($nodo->get_left())) {
        return $nodo;
    }

    return $self->_encontrar_minimo($nodo->get_left());
}

sub encontrar_minimo {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "El arbol está vacio.\n";
        return undef;
    }
    my $nodo_min = $self->_encontrar_minimo($self->{root});
    return $nodo_min->get_data();
}

sub encontrar_maximo {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "El arbol está vacio.\n";
        return undef;
    }
    my $nodo = $self->{root};
    while (defined($nodo->get_right())) {
        $nodo = $nodo->get_right();
    }
    return $nodo->get_data();
}

sub recorrido_inorden {
    my ($self) = @_;
    print "Recorrido INORDEN (ascendente): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_inorden_recursivo($self->{root});
    print "\n";
}

sub _inorden_recursivo {
    my ($self, $nodo_actual) = @_;

    return if !defined($nodo_actual);

    $self->_inorden_recursivo($nodo_actual->get_left());

    print $nodo_actual->get_data()->get_codigo() . " ";

    $self->_inorden_recursivo($nodo_actual->get_right());
}

sub recorrido_preorden {
    my ($self) = @_;
    print "Recorrido PREORDEN (raiz primero): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_preorden_recursivo($self->{root});
    print "\n";
}

sub _preorden_recursivo {
    my ($self, $nodo_actual) = @_;

    return if !defined($nodo_actual);

    print $nodo_actual->get_data()->get_codigo() . " ";

    $self->_preorden_recursivo($nodo_actual->get_left());

    $self->_preorden_recursivo($nodo_actual->get_right());
}

sub recorrido_postorden {
    my ($self) = @_;
    print "Recorrido POSTORDEN (raiz al final): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_postorden_recursivo($self->{root});
    print "\n";
}

sub _postorden_recursivo {
    my ($self, $nodo_actual) = @_;

    return if !defined($nodo_actual);

    $self->_postorden_recursivo($nodo_actual->get_left());

    $self->_postorden_recursivo($nodo_actual->get_right());

    print $nodo_actual->get_data()->get_codigo() . " ";
}

sub imprimir_arbol {
    my ($self) = @_;
    $self->_imprimir_recursivo($self->{root});
    print "\n";
}

sub _imprimir_recursivo {
    my ($self, $nodo) = @_;
    return if !defined($nodo);

    $self->_imprimir_recursivo($nodo->get_left());
    print $nodo->get_data()->get_codigo() . " ";
    $self->_imprimir_recursivo($nodo->get_right());
}

1;