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
    my ($self, $codigo) = @_;
    return undef if $self->is_empty();
    return $self->_buscar_recursivo($self->{raiz}, $codigo);
}

sub _buscar_recursivo {
    my ($self, $nodo, $codigo) = @_;
    return undef unless defined($nodo);

    my $pos = $nodo->get_pos_clave($codigo);
    if (defined($pos)) {
        return $nodo->get_clave_en_pos($pos);
    }

    if ($nodo->es_hoja()) { return undef; }

    my $pos_hijo = $nodo->encontrar_pos_hijo($codigo);
    my $hijo     = $nodo->get_hijo_en_pos($pos_hijo);
    return $self->_buscar_recursivo($hijo, $codigo);
}

sub insertar {
    my ($self, $suministro_obj) = @_;
    my $codigo = $suministro_obj->get_codigo();

    if ($self->is_empty()) {
        $self->{raiz} = Nodo->new();
        $self->{raiz}->agregar_clave_ordenada($suministro_obj);
        $self->{size}++;
        print "Insertado en la raiz\n";
        return;
    }

    if ($self->buscar($codigo)) {
        print " ERROR: El suministro con codigo '$codigo' ya existe en el Arbol B.\n";
        return;
    }

    return if $self->buscar($codigo);

    my ($mediana_obj, $nuevo_hijo_der) = $self->_insertar_recursivo($self->{raiz}, $suministro_obj);

    if (defined($mediana_obj)) {
        my $nueva_raiz = Nodo->new();
        $nueva_raiz->agregar_clave_ordenada($mediana_obj);
        $nueva_raiz->agregar_hijo_al_final($self->{raiz});
        $nueva_raiz->agregar_hijo_al_final($nuevo_hijo_der);
        $self->{raiz} = $nueva_raiz;
    }

    $self->{size}++;
    print "Insertado en el arbol\n";
}

sub _insertar_recursivo {
    my ($self, $nodo, $obj) = @_;
    my $codigo = $obj->get_codigo();

    if ($nodo->contiene_clave($codigo)) {
        return (undef, undef);
    }

    if ($nodo->es_hoja()) {
        $nodo->agregar_clave_ordenada($obj);
        if ($nodo->get_num_claves() > $self->{max_claves}) {
            return $self->_dividir($nodo);
        }
        return (undef, undef);
    }

    my $pos_hijo = $nodo->encontrar_pos_hijo($codigo);
    my $hijo     = $nodo->get_hijo_en_pos($pos_hijo);

    my ($mediana_obj, $nuevo_hijo_der) = $self->_insertar_recursivo($hijo, $obj);

    if (defined($mediana_obj)) {
        $nodo->agregar_clave_ordenada($mediana_obj);
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
    my $mediana_obj = $nodo_lleno->get_clave_en_pos($pos_mediana);
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
        my $tmp_obj = $nodo_lleno->get_clave_en_pos($k);
        $nodo_lleno->eliminar_clave($tmp_obj->get_codigo());
    }

    if (!$nodo_lleno->es_hoja()) {
        for (my $j = $nodo_lleno->get_num_hijos() - 1; $j > $pos_mediana; $j--) {
            $nodo_lleno->eliminar_hijo_en_pos($j);
        }
    }

    return ($mediana_obj, $nodo_derecho);
}

sub eliminar {
    my ($self, $codigo) = @_;
    return if $self->is_empty();
    return unless $self->buscar($codigo);

    $self->_eliminar_recursivo($self->{raiz}, $codigo);

    if (defined($self->{raiz}) && $self->{raiz}->get_num_claves() == 0 && !$self->{raiz}->es_hoja()) {
        $self->{raiz} = $self->{raiz}->get_hijo_en_pos(0);
    }

    $self->{size}--;
}

sub _eliminar_recursivo {
    my ($self, $nodo, $codigo) = @_;
    my $pos = $nodo->get_pos_clave($codigo);

    if (defined($pos)) {
        if ($nodo->es_hoja()) {
            $nodo->eliminar_clave($codigo);
            return;
        }

        my $hijo_izq = $nodo->get_hijo_en_pos($pos);
        my $predecesor_obj = $self->_encontrar_maximo_hoja($hijo_izq);

        $nodo->eliminar_clave($codigo);
        $nodo->agregar_clave_ordenada($predecesor_obj);

        $self->_eliminar_recursivo($hijo_izq, $predecesor_obj->get_codigo());
        return;
    }

    my $pos_hijo = $nodo->encontrar_pos_hijo($codigo);
    $self->_eliminar_recursivo($nodo->get_hijo_en_pos($pos_hijo), $codigo);
}

sub _encontrar_maximo_hoja {
    my ($self, $nodo) = @_;
    return $nodo->get_ultima_clave() if $nodo->es_hoja();
    return $self->_encontrar_maximo_hoja($nodo->get_hijo_en_pos($nodo->get_num_hijos() - 1));
}

1;