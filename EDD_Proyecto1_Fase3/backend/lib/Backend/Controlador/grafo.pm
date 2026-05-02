package Backend::Controlador::grafo;

use strict;
use warnings;
use Backend::Modelo::NodoGrafo;

package Backend::Controlador::_NodoCont;
sub new {
    my ($class, $data) = @_;
    bless { data => $data, siguiente => undef }, $class;
}
sub get_data { return $_[0]->{data}; }
sub get_siguiente { return $_[0]->{siguiente}; }
sub set_siguiente { my ($s, $n) = @_; $s->{siguiente} = $n; }

package Backend::Controlador::grafo;

sub new {
    my ($class) = @_;
    my $self = {
        vertices_cabeza => undef,
        cantidad => 0,
    };
    bless $self, $class;
    return $self;
}

sub esta_vacio {
    my ($self) = @_;
    return !defined($self->{vertices_cabeza}) ? 1 : 0;
}

sub agregar_vertice {
    my ($self, $id, $data) = @_;
    
    if (defined($self->buscar_vertice($id))) { 
        return 0; 
    }

    my $nodo_grafo = Backend::Modelo::NodoGrafo->new($id, $data);
    my $contenedor = Backend::Controlador::_NodoCont->new($nodo_grafo);

    if (!defined($self->{vertices_cabeza})) {
        $self->{vertices_cabeza} = $contenedor;
    } else {
        my $actual = $self->{vertices_cabeza};
        while (defined($actual->get_siguiente())) {
            $actual = $actual->get_siguiente();
        }
        $actual->set_siguiente($contenedor);
    }
    
    $self->{cantidad}++; 
    
    return 1;
}

sub buscar_vertice {
    my ($self, $id) = @_;
    my $actual = $self->{vertices_cabeza};
    while (defined($actual)) {
        if ($actual->get_data()->get_id() eq $id) {
            return $actual->get_data();
        }
        $actual = $actual->get_siguiente();
    }
    return undef;
}

sub agregar_arista {
    my ($self, $id_a, $id_b, $estado) = @_;
    
    return 0 if (defined $estado && $estado ne "ACTIVA");

    my $nodo_a = $self->buscar_vertice($id_a);
    my $nodo_b = $self->buscar_vertice($id_b);

    if (defined $nodo_a && defined $nodo_b) {
        unless ($nodo_a->es_vecino_de($id_b)) {
            $nodo_a->agregar_vecino($nodo_b);
            $nodo_b->agregar_vecino($nodo_a);
            return 1;
        }
    }
    return 0;
}

sub bfs_dos_saltos {
    my ($self, $id_origen) = @_;
    my $origen = $self->buscar_vertice($id_origen);
    return undef unless (defined $origen);

    my %visitados = ();
    $visitados{$id_origen} = 1;

    my $ptr = $origen->get_lista_adyacencia()->get_cabeza();
    while (defined $ptr) {
        $visitados{ $ptr->get_data()->get_id() } = 1;
        $ptr = $ptr->get_siguiente();
    }

    my $cola_inicio = Backend::Controlador::_NodoCont->new($origen);
    my $cola_fin = $cola_inicio;
    
    my $ptr_n1 = $origen->get_lista_adyacencia()->get_cabeza();
    while (defined $ptr_n1) {
        my $cont = Backend::Controlador::_NodoCont->new($ptr_n1->get_data());
        $cola_fin->set_siguiente($cont);
        $cola_fin = $cont;
        $ptr_n1 = $ptr_n1->get_siguiente();
    }

    my $resultado_inicio = undef;
    my $resultado_fin = undef;
    my $procesando = $cola_inicio->get_siguiente();

    while (defined $procesando) {
        my $ptr_n2 = $procesando->get_data()->get_lista_adyacencia()->get_cabeza();
        while (defined $ptr_n2) {
            my $id_c = $ptr_n2->get_data()->get_id();
            unless (exists $visitados{$id_c}) {
                $visitados{$id_c} = 1;
                my $nuevo = Backend::Controlador::_NodoCont->new($ptr_n2->get_data());
                if (!defined $resultado_inicio) {
                    $resultado_inicio = $nuevo;
                    $resultado_fin = $nuevo;
                } else {
                    $resultado_fin->set_siguiente($nuevo);
                    $resultado_fin = $nuevo;
                }
            }
            $ptr_n2 = $ptr_n2->get_siguiente();
        }
        $procesando = $procesando->get_siguiente();
    }
    return $resultado_inicio;
}

1;