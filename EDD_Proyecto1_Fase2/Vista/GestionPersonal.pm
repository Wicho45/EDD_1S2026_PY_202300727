package Vista::GestionPersonal;

use strict;
use warnings;
use Gtk3;
use utf8;

sub mostrar_gestion {
    my ($class, $arbol_usuarios) = @_;

    my $window = Gtk3::Window->new('toplevel');
    $window->set_title("Gestión de Personal Médico (AVL)");
    $window->set_default_size(900, 700);
    $window->set_position('center');

    my $vbox_principal = Gtk3::Box->new('vertical', 15);
    $vbox_principal->set_border_width(15);
    $window->add($vbox_principal);

    my $label_rec = Gtk3::Label->new();
    $label_rec->set_markup("<span size='large' weight='bold'>Visualización de Personal por Recorridos</span>");
    $vbox_principal->pack_start($label_rec, 0, 0, 0);

    my $notebook = Gtk3::Notebook->new();
    $vbox_principal->pack_start($notebook, 1, 1, 0);

    my $tabla_pre = _crear_tabla_personal();
    my $tabla_in  = _crear_tabla_personal();
    my $tabla_post = _crear_tabla_personal();

    $notebook->append_page($tabla_pre->{scroll}, Gtk3::Label->new("Pre-Orden"));
    $notebook->append_page($tabla_in->{scroll}, Gtk3::Label->new("In-Orden"));
    $notebook->append_page($tabla_post->{scroll}, Gtk3::Label->new("Post-Orden"));

    my $cb_personal = Gtk3::ComboBoxText->new();

    my $actualizar_combos = sub {
        $cb_personal->remove_all();
        _llenar_combo_recursivo($arbol_usuarios->{root}, $cb_personal);
    };

    my $refrescar_vistas = sub {
        $tabla_pre->{model}->clear();
        $tabla_in->{model}->clear();
        $tabla_post->{model}->clear();
        _llenar_recorrido($arbol_usuarios->{root}, $tabla_pre->{model}, "pre");
        _llenar_recorrido($arbol_usuarios->{root}, $tabla_in->{model}, "in");
        _llenar_recorrido($arbol_usuarios->{root}, $tabla_post->{model}, "post");
        $actualizar_combos->();
    };

    $refrescar_vistas->();

    my $frame_busqueda = Gtk3::Frame->new("Buscar Personal por No. Colegio");
    my $hbox_bus = Gtk3::Box->new('horizontal', 10);
    $hbox_bus->set_border_width(10);
    $frame_busqueda->add($hbox_bus);
    $vbox_principal->pack_start($frame_busqueda, 0, 0, 0);

    my $ent_busqueda = Gtk3::Entry->new();
    $ent_busqueda->set_placeholder_text("COL-XXXXX");
    $hbox_bus->pack_start($ent_busqueda, 1, 1, 0);

    my $btn_buscar = Gtk3::Button->new_with_label("Buscar");
    $hbox_bus->pack_start($btn_buscar, 0, 0, 0);

    $btn_buscar->signal_connect(clicked => sub {
        my $colegio = $ent_busqueda->get_text();
        my $nodo = $arbol_usuarios->buscar(undef, $colegio);
        if ($nodo) {
            my $u = $nodo->get_data();
            my $info = "Nombre: " . $u->get_username() . "\n" .
                        "No. Colegio: " . $u->get_numero_colegio() . "\n" .
                        "Departamento: " . $u->get_departamento() . "\n" .
                        "Especialidad: " . ($u->get_especialidad() || "N/A");
            _mensaje($window, 'info', "Usuario Encontrado", $info);
        } else {
            _mensaje($window, 'error', "Error", "No se encontró personal con ese número de colegio.");
        }
    });

    my $frame_eliminar = Gtk3::Frame->new("Eliminar Personal Médico");
    my $hbox_eli = Gtk3::Box->new('horizontal', 10);
    $hbox_eli->set_border_width(10);
    $frame_eliminar->add($hbox_eli);
    $vbox_principal->pack_start($frame_eliminar, 0, 0, 0);

    $hbox_eli->pack_start($cb_personal, 1, 1, 0);

    my $btn_eliminar = Gtk3::Button->new_with_label("Eliminar del Sistema");
    $hbox_eli->pack_start($btn_eliminar, 0, 0, 0);

    $btn_eliminar->signal_connect(clicked => sub {
        my $texto = $cb_personal->get_active_text();
        return unless $texto;
        my ($colegio) = $texto =~ /\[(.*?)\]/;
        
        $arbol_usuarios->eliminar($colegio);
        $refrescar_vistas->();
        _mensaje($window, 'info', "Éxito", "Usuario eliminado y árbol rebalanceado.");
    });

    my $btn_regresar = Gtk3::Button->new_with_label("Regresar al Panel Principal");
    $vbox_principal->pack_start($btn_regresar, 0, 0, 5);

    $btn_regresar->signal_connect(clicked => sub {
        $window->destroy();
    });

    $window->show_all();
    return $window;
}

sub _crear_tabla_personal {
    my $model = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String', 'Glib::String');
    my $treeview = Gtk3::TreeView->new_with_model($model);
    
    my @cols = ("No. Colegio", "Nombre", "Departamento", "Especialidad");
    for my $i (0..$#cols) {
        my $renderer = Gtk3::CellRendererText->new();
        my $column = Gtk3::TreeViewColumn->new_with_attributes($cols[$i], $renderer, text => $i);
        $treeview->append_column($column);
    }

    my $scroll = Gtk3::ScrolledWindow->new(undef, undef);
    $scroll->set_policy('automatic', 'automatic');
    $scroll->add($treeview);

    return { model => $model, scroll => $scroll };
}

sub _llenar_recorrido {
    my ($nodo, $model, $tipo) = @_;
    return unless $nodo;

    if ($tipo eq "pre") { _agregar_fila_personal($model, $nodo->get_data()); }
    _llenar_recorrido($nodo->get_left(), $model, $tipo);
    if ($tipo eq "in") { _agregar_fila_personal($model, $nodo->get_data()); }
    _llenar_recorrido($nodo->get_right(), $model, $tipo);
    if ($tipo eq "post") { _agregar_fila_personal($model, $nodo->get_data()); }
}

sub _agregar_fila_personal {
    my ($model, $u) = @_;
    my $iter = $model->append();
    $model->set($iter, 
        0 => $u->get_numero_colegio(), 
        1 => $u->get_username(), 
        2 => $u->get_departamento(), 
        3 => ($u->get_especialidad() || "N/A")
    );
}

sub _llenar_combo_recursivo {
    my ($nodo, $combo) = @_;
    return unless $nodo;
    _llenar_combo_recursivo($nodo->get_left(), $combo);
    $combo->append_text("[" . $nodo->get_data()->get_numero_colegio() . "] " . $nodo->get_data()->get_username());
    _llenar_combo_recursivo($nodo->get_right(), $combo);
}

sub _mensaje {
    my ($p, $t, $tit, $msg) = @_;
    my $d = Gtk3::MessageDialog->new($p, 'modal', $t, 'ok', $msg);
    $d->set_title($tit);
    $d->run();
    $d->destroy();
}

1;