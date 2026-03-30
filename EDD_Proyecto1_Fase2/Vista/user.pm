package Vista::user;

use strict;
use warnings;
use Gtk3;
use utf8;

sub mostrar_user {
    my ($class, $usuario_logueado, $lista_meds, $arbol_equipo, $arbol_suministros) = @_;

    my $window = Gtk3::Window->new('toplevel');
    $window->set_title("Panel de Usuario - Medtrack");
    $window->set_default_size(500, 600);
    $window->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 15);
    $vbox->set_border_width(20);
    $window->add($vbox);

    my $lbl_user = Gtk3::Label->new();
    $lbl_user->set_markup("<span size='x-large' weight='bold'>Bienvenido, " . $usuario_logueado->get_username() . "</span>");
    $vbox->pack_start($lbl_user, 0, 0, 10);

    my $btn_perfil = Gtk3::Button->new_with_label("Ver Mi Perfil");
    $btn_perfil->signal_connect(clicked => sub { _mostrar_perfil($window, $usuario_logueado); });
    $vbox->pack_start($btn_perfil, 0, 0, 5);

    $vbox->pack_start(Gtk3::Separator->new('horizontal'), 0, 0, 10);

    _crear_seccion_busqueda($vbox, "Consultar Medicamento (Código)", sub {
        my $cod = shift;
        if ($lista_meds->buscar($cod)) {
            my $actual = $lista_meds->{cabeza};
            while (defined $actual) {
                my $m = $actual->get_data();
                if ($m->get_codigo_medicamento() eq $cod) {
                    my $alerta = ($m->get_stock() < $m->get_nivel_reorden()) ? "\n\n¡ALERTA: STOCK BAJO!" : "";
                    _dialogo($window, "Medicamento Encontrado", 
                        "Nombre: " . $m->get_nombre_comercial() . 
                        "\nCantidad: " . $m->get_stock() . 
                        "\nVencimiento: " . $m->get_vencimiento() . $alerta);
                    return;
                }
                $actual = $actual->get_next();
            }
        } else {
            _dialogo($window, "Error", "No se encontró medicamento con código: $cod");
        }
    });

    _crear_seccion_busqueda($vbox, "Consultar Equipo Médico (Código)", sub {
        my $cod = shift;
        my $nodo = $arbol_equipo->buscar($cod);
        if (defined $nodo) {
            my $e = $nodo->get_data();
            _dialogo($window, "Equipo Médico Encontrado", 
                "ID: " . $e->get_codigo() . "\nNombre: " . $e->get_nombre() . 
                "\nFabricante: " . $e->get_fabricante() . "\nCantidad: " . $e->get_cantidad() . 
                "\nPrecio: Q" . $e->get_precio_unitario());
        } else { _dialogo($window, "Error", "No se encontró equipo con código: $cod"); }
    });

    _crear_seccion_busqueda($vbox, "Consultar Suministro (Código)", sub {
        my $cod = shift;
        my $sum = $arbol_suministros->buscar($cod);
        if (defined $sum) {
            my $alerta = ($sum->get_cantidad() < $sum->get_nivel_minimo()) ? "\n\n ¡ALERTA: STOCK BAJO!" : "";
            _dialogo($window, "Suministro Encontrado", 
                "Nombre: " . $sum->get_nombre() . "\nFabricante: " . $sum->get_fabricante() . 
                "\nPrecio: Q" . $sum->get_precio_unitario() . "\nCantidad: " . $sum->get_cantidad() . $alerta);
        } else { _dialogo($window, "Error", "No se encontró suministro con código: $cod"); }
    });

    my $btn_salir = Gtk3::Button->new_with_label("Cerrar Sesión");
    $vbox->pack_end($btn_salir, 0, 0, 10);
    $btn_salir->signal_connect(clicked => sub { $window->destroy(); });

    $window->show_all();
    return $window;
}

sub _crear_seccion_busqueda {
    my ($vbox, $titulo, $callback) = @_;
    my $lbl = Gtk3::Label->new($titulo);
    $lbl->set_halign('start');
    $vbox->pack_start($lbl, 0, 0, 0);
    my $hbox = Gtk3::Box->new('horizontal', 5);
    my $entry = Gtk3::Entry->new();
    my $btn = Gtk3::Button->new_with_label("Buscar");
    $hbox->pack_start($entry, 1, 1, 0);
    $hbox->pack_start($btn, 0, 0, 0);
    $vbox->pack_start($hbox, 0, 0, 0);
    $btn->signal_connect(clicked => sub {
        my $texto = $entry->get_text();
        if ($texto ne "") { $callback->($texto); }
    });
}

sub _mostrar_perfil {
    my ($parent, $u) = @_;
    my %tipos = (1 => "Médico Gral.", 2 => "Especialista", 3 => "Enfermería", 4 => "Técnico", 5 => "Admin");
    my $msg = "No. Colegio: " . $u->get_numero_colegio() . "\nNombre: " . $u->get_username() .
                "\nTipo: " . ($tipos{$u->get_tipo()} // "Otro") . "\nDepartamento: " . $u->get_departamento() .
                "\nEspecialidad: " . ($u->get_especialidad() || "N/A");
    _dialogo($parent, "Mi Perfil", $msg);
}

sub _dialogo {
    my ($parent, $titulo, $msj) = @_;
    my $dialog = Gtk3::MessageDialog->new($parent, 'modal', 'info', 'ok', $msj);
    $dialog->set_title($titulo); $dialog->run(); $dialog->destroy();
}

1;