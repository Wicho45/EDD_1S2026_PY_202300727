package Controlador::avl;

use strict;
use warnings;

use Modelo::Nodo;
use constant Nodo => 'Modelo::Nodo';

sub new {
    my ($class) = @_;
    my $self = {
        root => undef,
        size => 0,
    };
    bless $self, $class;
    return $self;
}

sub is_empty  {
    return !defined($_[0]->{root}) ? 1 : 0;
}

sub get_size { 
    return $_[0]->{size}; 
}

sub _altura {
    my ($self, $nodo) = @_;
    return -1 unless defined($nodo);
    return $nodo->get_altura();
}

sub _factor_equilibrio {
    my ($self, $nodo) = @_;
    return 0 unless defined($nodo);
    return $self->_altura($nodo->get_right()) - $self->_altura($nodo->get_left());
}

sub _actualizar_altura {
    my ($self, $nodo) = @_;
    return unless defined($nodo);

    my $h_izq = $self->_altura($nodo->get_left());
    my $h_der = $self->_altura($nodo->get_right());

    my $nueva_altura = 1 + ($h_izq > $h_der ? $h_izq : $h_der);
    $nodo->set_altura($nueva_altura);
}

sub _rotar_derecha {
    my ($self, $y) = @_;

    my $x  = $y->get_left();   
    my $T2 = $x->get_right();  

    $x->set_right($y);   
    $y->set_left($T2);   

    $self->_actualizar_altura($y);
    $self->_actualizar_altura($x);

    return $x;
}

sub _rotar_izquierda {
    my ($self, $x) = @_;

    my $y  = $x->get_right();   
    my $T2 = $y->get_left();    

    $y->set_left($x); 
    $x->set_right($T2);
    
    $self->_actualizar_altura($x);
    $self->_actualizar_altura($y);

    return $y;
}

sub _balancear {
    my ($self, $nodo) = @_;

    return undef unless defined($nodo);

    $self->_actualizar_altura($nodo);

    my $fe = $self->_factor_equilibrio($nodo);

    if ($fe == -2 && $self->_factor_equilibrio($nodo->get_left()) <= 0) {
        print "  [ ----> AVL] Rotacion DERECHA en nodo " . $nodo->get_data()->get_numero_colegio() . " (caso LL)\n";
        return $self->_rotar_derecha($nodo);
    }

    if ($fe == -2 && $self->_factor_equilibrio($nodo->get_left()) > 0) {
        print "  [--> AVL] Rotacion IZQUIERDA en hijo izquierdo " . $nodo->get_left()->get_data()->get_numero_colegio() . " (caso LR paso 1)\n";
        print "  [--> AVL] Rotacion DERECHA en nodo " . $nodo->get_data()->get_numero_colegio() . " (caso LR paso 2)\n";
        $nodo->set_left($self->_rotar_izquierda($nodo->get_left()));
        return $self->_rotar_derecha($nodo);
    }

    if ($fe == 2 && $self->_factor_equilibrio($nodo->get_right()) >= 0) {
        print "  [-> AVL] Rotacion IZQUIERDA en nodo " . $nodo->get_data()->get_numero_colegio() . " (caso RR)\n";
        return $self->_rotar_izquierda($nodo);
    }

    if ($fe == 2 && $self->_factor_equilibrio($nodo->get_right()) < 0) {
        print "  [AVL] Rotacion DERECHA en hijo derecho " . $nodo->get_right()->get_data()->get_numero_colegio() . " (caso RL paso 1)\n";
        print "  [AVL] Rotacion IZQUIERDA en nodo " . $nodo->get_data()->get_numero_colegio() . " (caso RL paso 2)\n";
        $nodo->set_right($self->_rotar_derecha($nodo->get_right()));
        return $self->_rotar_izquierda($nodo);
    }

    return $nodo;
}

sub insertar {
    my ($self, $usuario_obj) = @_; 

    my $id_nuevo = $self->_extraer_id_numerico($usuario_obj->get_numero_colegio());

    my ($nueva_raiz, $insertado) = $self->_insertar_recursivo($self->{root}, $usuario_obj, $id_nuevo);
    $self->{root} = $nueva_raiz;

    if ($insertado) {
        $self->{size}++;
        print "Valor '" . $usuario_obj->get_numero_colegio() . "' insertado exitosamente.\n";
    }
}

sub _insertar_recursivo {
    my ($self, $nodo_actual, $usuario_obj, $id_nuevo) = @_;

    if (!defined($nodo_actual)) {
        return (Modelo::Nodo->new($usuario_obj), 1);
    }

    my $usuario_en_nodo = $nodo_actual->get_data();
    my $id_actual = $self->_extraer_id_numerico($usuario_en_nodo->get_numero_colegio());

    if ($id_nuevo < $id_actual) {
        my ($hijo_izq, $ins) = $self->_insertar_recursivo($nodo_actual->get_left(), $usuario_obj, $id_nuevo);
        $nodo_actual->set_left($hijo_izq);
        
        return ($self->_balancear($nodo_actual), $ins); 

    } elsif ($id_nuevo > $id_actual) {
        my ($hijo_der, $ins) = $self->_insertar_recursivo($nodo_actual->get_right(), $usuario_obj, $id_nuevo);
        $nodo_actual->set_right($hijo_der);
        
        return ($self->_balancear($nodo_actual), $ins); 

    } else {
        print "Error: El número de colegio " . $usuario_obj->get_numero_colegio() . " ya existe.\n";
        return ($nodo_actual, 0);
    }
}

sub eliminar {
    my ($self, $colegio_str) = @_;
    return if $self->is_empty();

    my $id_eliminar = $self->_extraer_id_numerico($colegio_str);
    my ($nueva_raiz, $eliminado) = $self->_eliminar_recursivo($self->{root}, $id_eliminar);
    $self->{root} = $nueva_raiz;
    
    if ($eliminado) {
        $self->{size}--;
        print "Valor '$colegio_str' eliminado exitosamente.\n";
    }
}

sub _eliminar_recursivo {
    my ($self, $nodo_actual, $id_eliminar) = @_;
    return (undef, 0) unless defined($nodo_actual);

    my $id_actual = $self->_extraer_id_numerico($nodo_actual->get_data()->get_numero_colegio());
    my $eliminado = 0;

    if ($id_eliminar < $id_actual) {
        my ($hijo_izq, $e) = $self->_eliminar_recursivo($nodo_actual->get_left(), $id_eliminar);
        $nodo_actual->set_left($hijo_izq);
        $eliminado = $e;
    } elsif ($id_eliminar > $id_actual) {
        my ($hijo_der, $e) = $self->_eliminar_recursivo($nodo_actual->get_right(), $id_eliminar);
        $nodo_actual->set_right($hijo_der);
        $eliminado = $e;
    } else {
        $eliminado = 1;
        if (!defined($nodo_actual->get_left())) { return ($nodo_actual->get_right(), 1); }
        elsif (!defined($nodo_actual->get_right())) { return ($nodo_actual->get_left(), 1); }
        
        my $sucesor = $self->_encontrar_minimo($nodo_actual->get_right());
        $nodo_actual->set_data($sucesor->get_data());
        my $id_sucesor = $self->_extraer_id_numerico($sucesor->get_data()->get_numero_colegio());
        my ($hijo_der_nuevo, $unused) = $self->_eliminar_recursivo($nodo_actual->get_right(), $id_sucesor);
        $nodo_actual->set_right($hijo_der_nuevo);
    }
    return ($self->_balancear($nodo_actual), $eliminado);
}

sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    return $nodo unless defined($nodo->get_left());
    return $self->_encontrar_minimo($nodo->get_left());
}

sub buscar {
    my ($self, $username, $num_colegio) = @_;
    return undef if $self->is_empty();
    
    if (defined($num_colegio) && $num_colegio =~ /COL-\d+/) {
        return $self->_buscar_por_colegio($self->{root}, $num_colegio);
    } 
    elsif (defined($username)) {
        return $self->_buscar_por_username($self->{root}, $username);
    }
    return undef;
}

sub _buscar_por_colegio {
    my ($self, $nodo, $target_col) = @_;
    return undef unless defined($nodo);

    my $id_actual = $self->_extraer_id_numerico($nodo->get_data()->get_numero_colegio());
    my $id_buscar = $self->_extraer_id_numerico($target_col);

    if ($id_actual == $id_buscar) {
        return $nodo;
    }
    return ($id_buscar < $id_actual) 
        ? $self->_buscar_por_colegio($nodo->get_left(), $target_col)
        : $self->_buscar_por_colegio($nodo->get_right(), $target_col);
}

sub _buscar_por_username {
    my ($self, $nodo, $target_user) = @_;
    return undef unless defined($nodo);

    my $izq = $self->_buscar_por_username($nodo->get_left(), $target_user);
    return $izq if defined($izq);

    return $nodo if $nodo->get_data()->get_username() eq $target_user;

    return $self->_buscar_por_username($nodo->get_right(), $target_user);
}

sub recorrido_inorden {
    my ($self) = @_;
    print "Recorrido INORDEN (ascendente): ";
    if ($self->is_empty()) { print "(arbol vacio)\n"; return; }
    $self->_inorden_rec($self->{root});
    print "\n";
}

sub _inorden_rec {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    $self->_inorden_rec($nodo->get_left());   
    print $nodo->get_data()->get_numero_colegio() . " ";
    $self->_inorden_rec($nodo->get_right());  
}

sub recorrido_preorden {
    my ($self) = @_;
    print "Recorrido PREORDEN (raiz primero): ";
    if ($self->is_empty()) { print "(arbol vacio)\n"; return; }
    $self->_preorden_rec($self->{root});
    print "\n";
}

sub _preorden_rec {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    print $nodo->get_data()->get_numero_colegio() . " ";
    $self->_preorden_rec($nodo->get_left());  
    $self->_preorden_rec($nodo->get_right());  
}

sub recorrido_postorden {
    my ($self) = @_;
    print "Recorrido POSTORDEN (raiz al final): ";
    if ($self->is_empty()) { print "(arbol vacio)\n"; return; }
    $self->_postorden_rec($self->{root});
    print "\n";
}

sub _postorden_rec {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    $self->_postorden_rec($nodo->get_left());   
    $self->_postorden_rec($nodo->get_right()); 
    print $nodo->get_data()->get_numero_colegio() . " ";
}

sub encontrar_minimo {
    my ($self) = @_;
    return undef if $self->is_empty();
    return $self->_encontrar_minimo($self->{root})->get_data();
}

sub encontrar_maximo {
    my ($self) = @_;
    return undef if $self->is_empty();
    my $nodo = $self->{root};
    $nodo = $nodo->get_right() while defined($nodo->get_right());
    return $nodo->get_data();
}

sub imprimir_arbol {
    my ($self) = @_;
    $self->_imprimir_rec($self->{root});
    print "\n";
}

sub _imprimir_rec {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    $self->_imprimir_rec($nodo->get_left());
    print $nodo->get_data()->get_numero_colegio() . "(h=" . $nodo->get_altura() .
        ",fe=" . $self->_factor_equilibrio($nodo) . ") ";
    $self->_imprimir_rec($nodo->get_right());
}

sub _extraer_id_numerico {
    my ($self, $colegio_str) = @_;
    return 0 unless defined $colegio_str;
    my ($num) = $colegio_str =~ /(\d+)/;
    return int($num || 0);
}

1;