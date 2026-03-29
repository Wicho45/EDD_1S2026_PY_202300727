package Controlador::btree;

use strict;
use warnings;

use Modelo::NodoB;
use constant Nodo => 'Modelo::NodoB';

sub new {
    my ($class, $orden) = @_;

    $orden = 4 unless defined($orden) && $orden >= 2;

    my $self = {
        raiz   => undef,
        orden  => $orden,
        max_claves => $orden - 1,
        size => 0,
    };

    bless $self, $class;
    return $self;
}

sub get_orden  { return $_[0]->{orden}; }
sub get_size { return $_[0]->{size}; }
sub is_empty { return !defined($_[0]->{raiz}) ? 1 : 0; }

sub buscar {
    my ($self, $val) = @_;
    return 0 if $self->is_empty();
    return $self->_buscar_recursivo($self->{raiz}, $val);
}

sub _buscar_recursivo {
    my ($self, $nodo, $val) = @_;
    return 0 unless defined($nodo);

    if ($nodo->contiene_clave($val)) {
        return 1;
    }

    if ($nodo->es_hoja()) {
        return 0;
    }

    my $pos_hijo = $nodo->encontrar_pos_hijo($val);
    my $hijo     = $nodo->get_hijo_en_pos($pos_hijo);

    return $self->_buscar_recursivo($hijo, $val);
}

sub insertar {
    my ($self, $suministro_obj) = @_;
    my $val = $suministro_obj->get_codigo();

    if ($self->is_empty()) {
        $self->{raiz} = Nodo->new();
        $self->{raiz}->agregar_clave_ordenada($val);
        $self->{size}++;
        return;
    }

    my ($mediana, $nuevo_hijo_der) = $self->_insertar_recursivo($self->{raiz}, $val);

    if (defined($mediana)) {
        my $nueva_raiz = Nodo->new();
        $nueva_raiz->agregar_clave_ordenada($mediana);
        $nueva_raiz->agregar_hijo_al_final($self->{raiz});
        $nueva_raiz->agregar_hijo_al_final($nuevo_hijo_der);
        $self->{raiz} = $nueva_raiz;
    }
    $self->{size}++;
}

sub _insertar_recursivo {
    my ($self, $nodo, $val) = @_;

    if ($nodo->contiene_clave($val)) {
        $self->{size}--;
        return (undef, undef);
    }

    if ($nodo->es_hoja()) {
        $nodo->agregar_clave_ordenada($val);
        if ($nodo->get_num_claves() > $self->{max_claves}) {
            return $self->_dividir($nodo);
        }
        return (undef, undef);
    }

    my $pos_hijo = $nodo->encontrar_pos_hijo($val);
    my $hijo     = $nodo->get_hijo_en_pos($pos_hijo);

    my ($mediana, $nuevo_hijo_der) = $self->_insertar_recursivo($hijo, $val);

    if (defined($mediana)) {
        $nodo->agregar_clave_ordenada($mediana);
        $nodo->insertar_hijo_en_pos($pos_hijo + 1, $nuevo_hijo_der);

        if ($nodo->get_num_claves() > $self->{max_claves}) {
            return $self->_dividir($nodo);
        }
    }
    return (undef, undef);
}

sub _dividir {
    my ($self, $nodo_lleno) = @_;

    my $total_claves = $nodo_lleno->get_num_claves();
    my $pos_mediana = int($total_claves / 2);
    my $mediana = $nodo_lleno->get_clave_en_pos($pos_mediana);

    my $nodo_derecho = Nodo->new();

    for (my $i = $pos_mediana + 1; $i < $total_claves; $i++) {
        $nodo_derecho->agregar_clave_ordenada($nodo_lleno->get_clave_en_pos($i));
    }

    if (!$nodo_lleno->es_hoja()) {
        my $total_hijos = $nodo_lleno->get_num_hijos();
        for (my $j = $pos_mediana + 1; $j < $total_hijos; $j++) {
            $nodo_derecho->agregar_hijo_al_final($nodo_lleno->get_hijo_en_pos($j));
        }
    }

    for (my $k = $total_claves - 1; $k >= $pos_mediana; $k--) {
        $nodo_lleno->eliminar_clave($nodo_lleno->get_clave_en_pos($k));
    }

    if (!$nodo_derecho->es_hoja()) {
        for (my $j = $nodo_lleno->get_num_hijos() - 1; $j > $pos_mediana; $j--) {
            $nodo_lleno->eliminar_hijo_en_pos($j);
        }
    }

    return ($mediana, $nodo_derecho);
}

sub eliminar {
    my ($self, $val) = @_;
    return if $self->is_empty();

    if (!$self->buscar($val)) {
        return;
    }

    $self->_eliminar_recursivo($self->{raiz}, $val);

    if (defined($self->{raiz}) && $self->{raiz}->get_num_claves() == 0 && !$self->{raiz}->es_hoja()) {
        $self->{raiz} = $self->{raiz}->get_hijo_en_pos(0);
    }
    $self->{size}--;
}

sub _eliminar_recursivo {
    my ($self, $nodo, $val) = @_;

    if ($nodo->contiene_clave($val)) {
        if ($nodo->es_hoja()) {
            $nodo->eliminar_clave($val);
            return;
        }

        my $pos_clave = $nodo->get_pos_clave($val);
        my $hijo_izq  = $nodo->get_hijo_en_pos($pos_clave);
        my $predecesor = $self->_encontrar_maximo_hoja($hijo_izq);

        $nodo->eliminar_clave($val);
        $nodo->agregar_clave_ordenada($predecesor);
        $self->_eliminar_recursivo($hijo_izq, $predecesor);
        return;
    }

    my $pos_hijo = $nodo->encontrar_pos_hijo($val);
    $self->_eliminar_recursivo($nodo->get_hijo_en_pos($pos_hijo), $val);
}

sub _encontrar_maximo_hoja {
    my ($self, $nodo) = @_;
    return $nodo->get_ultima_clave() if $nodo->es_hoja();
    return $self->_encontrar_maximo_hoja($nodo->get_hijo_en_pos($nodo->get_num_hijos() - 1));
}

sub imprimir_arbol {
    my ($self) = @_;
    return if $self->is_empty();

    my @cola = ({ nodo => $self->{raiz}, nivel => 0 });
    my $nivel_actual = 0;

    while (@cola) {
        my $item = shift @cola;
        if ($item->{nivel} > $nivel_actual) {
            $nivel_actual = $item->{nivel};
            print "\n";
        }

        my $nodo = $item->{nodo};
        my $claves = "";
        my $c = $nodo->get_claves_head();
        while (defined($c)) {
            $claves .= $c->{val} . ",";
            $c = $c->{sig};
        }
        print "[$claves] ";

        my $h = $nodo->get_hijos_head();
        while (defined($h)) {
            push @cola, { nodo => $h->{hijo}, nivel => $item->{nivel} + 1 };
            $h = $h->{sig};
        }
    }
    print "\n";
}

1;