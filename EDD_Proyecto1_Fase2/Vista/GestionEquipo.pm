package Vista::GestionEquipo;

use strict;
use warnings;
use Gtk3;
use utf8;
use Modelo::Equipo;

sub mostrar_gestion {
    my ($class, $arbol_equipo) = @_;

    my $window = Gtk3::Window->new('toplevel');
    $window->set_title("Gestión de Inventario de Equipos (BST)");
    $window->set_default_size(800, 750);
    $window->set_position('center');

    my $vbox_principal = Gtk3::Box->new('vertical', 15);
    $vbox_principal->set_border_width(15);
    $window->add($vbox_principal);

    # Logo
    my $ruta_logo = "imagenes/logo.png"; 
    if (-e $ruta_logo) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file_at_scale($ruta_logo, 100, 100, 1);
        my $logo = Gtk3::Image->new_from_pixbuf($pixbuf);
        $vbox_principal->pack_start($logo, 0, 0, 5);
    }

    my $label_rec = Gtk3::Label->new();
    $label_rec->set_markup("<span size='large' weight='bold'>Visualización de Inventario</span>");
    $vbox_principal->pack_start($label_rec, 0, 0, 0);

    my $notebook = Gtk3::Notebook->new();
    $vbox_principal->pack_start($notebook, 1, 1, 0);

    my $tabla_pre = _crear_tabla_recorrido();
    my $tabla_in  = _crear_tabla_recorrido();
    my $tabla_post = _crear_tabla_recorrido();

    $notebook->append_page($tabla_pre->{scroll}, Gtk3::Label->new("Pre-Orden"));
    $notebook->append_page($tabla_in->{scroll}, Gtk3::Label->new("In-Orden"));
    $notebook->append_page($tabla_post->{scroll}, Gtk3::Label->new("Post-Orden"));

    my $cb_equipos = Gtk3::ComboBoxText->new();

    my $actualizar_combo = sub {
        $cb_equipos->remove_all();
        _llenar_combo_recursivo($arbol_equipo->{root}, $cb_equipos);
    };

    my $refrescar_vistas = sub {
        $tabla_pre->{model}->clear();
        $tabla_in->{model}->clear();
        $tabla_post->{model}->clear();
        _llenar_recorrido($arbol_equipo->{root}, $tabla_pre->{model}, "pre");
        _llenar_recorrido($arbol_equipo->{root}, $tabla_in->{model}, "in");
        _llenar_recorrido($arbol_equipo->{root}, $tabla_post->{model}, "post");
        $actualizar_combo->();
    };

    $refrescar_vistas->();

    my $frame_busqueda = Gtk3::Frame->new("Búsqueda de Equipo");
    my $hbox_bus = Gtk3::Box->new('horizontal', 10);
    $hbox_bus->set_border_width(10);
    $frame_busqueda->add($hbox_bus);
    $vbox_principal->pack_start($frame_busqueda, 0, 0, 0);

    my $ent_busqueda = Gtk3::Entry->new();
    $ent_busqueda->set_placeholder_text("Ingrese código de equipo...");
    $hbox_bus->pack_start($ent_busqueda, 1, 1, 0);

    my $btn_buscar = Gtk3::Button->new_with_label("Buscar");
    $hbox_bus->pack_start($btn_buscar, 0, 0, 0);

    $btn_buscar->signal_connect(clicked => sub {
        my $codigo = $ent_busqueda->get_text();
        my $nodo = $arbol_equipo->buscar($codigo);
        if ($nodo) {
            my $eq = $nodo->get_data();
            my $info = "Código: " . $eq->get_codigo() . "\n" .
                        "Nombre: " . $eq->get_nombre() . "\n" .
                        "Fabricante: " . $eq->get_fabricante() . "\n" .
                        "Stock: " . $eq->get_cantidad() . "\n" .
                        "Precio: Q" . $eq->get_precio_unitario();
            _mensaje($window, 'info', "Equipo Encontrado", $info);
        } else {
            _mensaje($window, 'error', "Error", "Equipo no encontrado.");
        }
    });

    my $frame_eliminar = Gtk3::Frame->new("Eliminar Equipo");
    my $hbox_eli = Gtk3::Box->new('horizontal', 10);
    $hbox_eli->set_border_width(10);
    $frame_eliminar->add($hbox_eli);
    $vbox_principal->pack_start($frame_eliminar, 0, 0, 0);

    $hbox_eli->pack_start($cb_equipos, 1, 1, 0);

    my $btn_eliminar = Gtk3::Button->new_with_label("Eliminar Equipo");
    $hbox_eli->pack_start($btn_eliminar, 0, 0, 0);

    $btn_eliminar->signal_connect(clicked => sub {
        my $texto = $cb_equipos->get_active_text();
        return unless $texto;
        my ($codigo) = $texto =~ /\[(.*?)\]/;
        
        $arbol_equipo->eliminar($codigo);
        $refrescar_vistas->();
        _mensaje($window, 'info', "Éxito", "Equipo eliminado correctamente.");
    });

    my $btn_registrar = Gtk3::Button->new_with_label("Registrar Nuevo Equipo");
    $vbox_principal->pack_start($btn_registrar, 0, 0, 0);

    $btn_registrar->signal_connect(clicked => sub {
        _dialogo_registro($window, $arbol_equipo, $refrescar_vistas);
    });

    # Botón Regresar
    my $btn_regresar = Gtk3::Button->new_with_label("Regresar al Admin");
    $vbox_principal->pack_start($btn_regresar, 0, 0, 5);

    $btn_regresar->signal_connect(clicked => sub {
        $window->destroy();
    });

    $window->show_all();
    return $window;
}

sub _crear_tabla_recorrido {
    my $model = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String');
    my $treeview = Gtk3::TreeView->new_with_model($model);
    
    my @cols = ("Código", "Nombre", "Fabricante");
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

    if ($tipo eq "pre") { _agregar_fila($model, $nodo->get_data()); }
    _llenar_recorrido($nodo->get_left(), $model, $tipo);
    if ($tipo eq "in") { _agregar_fila($model, $nodo->get_data()); }
    _llenar_recorrido($nodo->get_right(), $model, $tipo);
    if ($tipo eq "post") { _agregar_fila($model, $nodo->get_data()); }
}

sub _agregar_fila {
    my ($model, $eq) = @_;
    my $iter = $model->append();
    $model->set($iter, 0 => $eq->get_codigo(), 1 => $eq->get_nombre(), 2 => $eq->get_fabricante());
}

sub _llenar_combo_recursivo {
    my ($nodo, $combo) = @_;
    return unless $nodo;
    _llenar_combo_recursivo($nodo->get_left(), $combo);
    $combo->append_text("[" . $nodo->get_data()->get_codigo() . "] " . $nodo->get_data()->get_nombre());
    _llenar_combo_recursivo($nodo->get_right(), $combo);
}

sub _dialogo_registro {
    my ($parent, $arbol, $cb_refrescar) = @_;
    my $dialog = Gtk3::Dialog->new("Nuevo Equipo", $parent, 'modal', 'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok');
    my $content = $dialog->get_content_area();
    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(10);
    $grid->set_column_spacing(10);
    $grid->set_border_width(15);
    $content->add($grid);

    my @campos = ("Código", "Nombre", "Fabricante", "Precio Unitario", "Cantidad", "Fecha Ingreso", "Nivel Mínimo");
    my %entries;

    for my $i (0..$#campos) {
        $grid->attach(Gtk3::Label->new($campos[$i]), 0, $i, 1, 1);
        $entries{$campos[$i]} = Gtk3::Entry->new();
        $grid->attach($entries{$campos[$i]}, 1, $i, 1, 1);
    }

    $dialog->show_all();

    while (1) {
        my $response = $dialog->run();
        
        if ($response eq 'ok') {
            my $hay_vacios = 0;
            foreach my $nombre_campo (@campos) {
                my $texto = $entries{$nombre_campo}->get_text();
                
                $texto =~ s/^\s+|\s+$//g;
                if ($texto eq "") {
                    $hay_vacios = 1;
                    last;
                }
            }

            if ($hay_vacios) {
                _mensaje($dialog, 'error', "Campos Incompletos", "Por favor, llene todos los campos para registrar el equipo.");
                next;
            } else {
                my $nuevo = Modelo::Equipo->new(
                    $entries{"Código"}->get_text(), $entries{"Nombre"}->get_text(),
                    $entries{"Fabricante"}->get_text(), $entries{"Precio Unitario"}->get_text(),
                    $entries{"Cantidad"}->get_text(), $entries{"Fecha Ingreso"}->get_text(),
                    $entries{"Nivel Mínimo"}->get_text()
                );
                $arbol->insertar($nuevo);
                $cb_refrescar->();
                last; 
            }
        } else {
            last; 
        }
    }
    
    $dialog->destroy();
}

sub _mensaje {
    my ($p, $t, $tit, $msg) = @_;
    my $d = Gtk3::MessageDialog->new($p, 'modal', $t, 'ok', $msg);
    $d->set_title($tit);
    $d->run();
    $d->destroy();
}

1;