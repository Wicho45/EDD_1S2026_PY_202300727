package Vista::GestionSuministros;

use strict;
use warnings;
use Gtk3;
use utf8;
use Modelo::Suministro;

sub mostrar_gestion {
    my ($class, $arbol_suministros) = @_;

    my $window = Gtk3::Window->new('toplevel');
    $window->set_title("Gestión de Inventario de Suministros (Árbol B)");
    $window->set_default_size(850, 600);
    $window->set_position('center');

    my $vbox_principal = Gtk3::Box->new('vertical', 15);
    $vbox_principal->set_border_width(15);
    $window->add($vbox_principal);

    my $label_rec = Gtk3::Label->new();
    $label_rec->set_markup("<span size='large' weight='bold'>Visualización In-Orden de Suministros</span>");
    $vbox_principal->pack_start($label_rec, 0, 0, 0);

    my $model = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String', 'Glib::String');
    my $treeview = Gtk3::TreeView->new_with_model($model);
    
    my @cols = ("Código", "Nombre", "Fabricante", "Cantidad");
    for my $i (0..$#cols) {
        my $renderer = Gtk3::CellRendererText->new();
        my $column = Gtk3::TreeViewColumn->new_with_attributes($cols[$i], $renderer, text => $i);
        $treeview->append_column($column);
    }

    my $scroll = Gtk3::ScrolledWindow->new(undef, undef);
    $scroll->set_policy('automatic', 'automatic');
    $scroll->add($treeview);
    $vbox_principal->pack_start($scroll, 1, 1, 0);

    my $cb_suministros = Gtk3::ComboBoxText->new();

    my $actualizar_lista = sub {
        $model->clear();
        $cb_suministros->remove_all();
        _recorrido_inorden_suministros($arbol_suministros->{raiz}, $model, $cb_suministros);
    };

    $actualizar_lista->();

    my $frame_busqueda = Gtk3::Frame->new("Búsqueda de Suministro");
    my $hbox_bus = Gtk3::Box->new('horizontal', 10);
    $hbox_bus->set_border_width(10);
    $frame_busqueda->add($hbox_bus);
    $vbox_principal->pack_start($frame_busqueda, 0, 0, 0);

    my $ent_busqueda = Gtk3::Entry->new();
    $ent_busqueda->set_placeholder_text("Ingrese código...");
    $hbox_bus->pack_start($ent_busqueda, 1, 1, 0);

    my $btn_buscar = Gtk3::Button->new_with_label("Buscar");
    $hbox_bus->pack_start($btn_buscar, 0, 0, 0);

    $btn_buscar->signal_connect(clicked => sub {
        my $codigo = $ent_busqueda->get_text();
        my $objeto = $arbol_suministros->buscar($codigo); 
        if ($objeto) {
            my $info = "Nombre: " . $objeto->get_nombre() . "\n" .
                        "Fabricante: " . $objeto->get_fabricante() . "\n" .
                        "Cantidad: " . $objeto->get_cantidad();
            _mensaje($window, 'info', "Suministro Encontrado", $info);
        } else {
            _mensaje($window, 'error', "Error", "Suministro no encontrado.");
        }
    });

    my $frame_eliminar = Gtk3::Frame->new("Eliminar Suministro");
    my $hbox_eli = Gtk3::Box->new('horizontal', 10);
    $hbox_eli->set_border_width(10);
    $frame_eliminar->add($hbox_eli);
    $vbox_principal->pack_start($frame_eliminar, 0, 0, 0);

    $hbox_eli->pack_start($cb_suministros, 1, 1, 0);

    my $btn_eliminar = Gtk3::Button->new_with_label("Eliminar");
    $hbox_eli->pack_start($btn_eliminar, 0, 0, 0);

    $btn_eliminar->signal_connect(clicked => sub {
        my $texto = $cb_suministros->get_active_text();
        return unless $texto;
        my ($codigo) = $texto =~ /\[(.*?)\]/;
        $arbol_suministros->eliminar($codigo);
        $actualizar_lista->();
        _mensaje($window, 'info', "Éxito", "Suministro '$codigo' eliminado.");
    });

    my $btn_registrar = Gtk3::Button->new_with_label("Registrar Nuevo Suministro");
    $vbox_principal->pack_start($btn_registrar, 0, 0, 0);

    $btn_registrar->signal_connect(clicked => sub {
        _dialogo_registro($window, $arbol_suministros, $actualizar_lista);
    });

    my $btn_regresar = Gtk3::Button->new_with_label("Regresar al Admin");
    $vbox_principal->pack_start($btn_regresar, 0, 0, 5);
    $btn_regresar->signal_connect(clicked => sub { $window->destroy(); });

    $window->show_all();
    return $window;
}

sub _recorrido_inorden_suministros {
    my ($nodo, $model, $combo) = @_;
    return unless defined($nodo);

    my $num_claves = $nodo->get_num_claves();
    my $es_hoja = $nodo->es_hoja();

    for (my $i = 0; $i < $num_claves; $i++) {
        if (!$es_hoja) {
            _recorrido_inorden_suministros($nodo->get_hijo_en_pos($i), $model, $combo);
        }
        
        my $suministro = $nodo->get_clave_en_pos($i);
        my $cod = $suministro->get_codigo();

        my $iter = $model->append();
        $model->set($iter, 
            0 => $cod, 
            1 => $suministro->get_nombre(), 
            2 => $suministro->get_fabricante(), 
            3 => $suministro->get_cantidad()
        );

        $combo->append_text("[" . $cod . "] " . $suministro->get_nombre());
    }

    if (!$es_hoja) {
        _recorrido_inorden_suministros($nodo->get_hijo_en_pos($num_claves), $model, $combo);
    }
}

sub _dialogo_registro {
    my ($parent, $arbol, $cb_refrescar) = @_;
    my $dialog = Gtk3::Dialog->new("Nuevo Suministro", $parent, 'modal', 'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok');
    my $content = $dialog->get_content_area();
    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(10); 
    $grid->set_column_spacing(10); 
    $grid->set_border_width(15);
    $content->add($grid);

    my @campos = ("Código", "Nombre", "Fabricante", "Precio Unitario", "Cantidad", "Fecha Vencimiento", "Nivel Mínimo");
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
            my $vacio = 0;
            my $codigo = $entries{"Código"}->get_text();
            $codigo =~ s/^\s+|\s+$//g; # Limpiar espacios

            foreach my $c (@campos) {
                my $val = $entries{$c}->get_text();
                $val =~ s/^\s+|\s+$//g;
                if ($val eq "") { $vacio = 1; last; }
            }

            if ($vacio) {
                _mensaje($dialog, 'error', "Error", "Todos los campos son obligatorios.");
                next;
            } 
            
            if ($arbol->buscar($codigo)) {
                _mensaje($dialog, 'error', "Código en uso", "El código '$codigo' ya está registrado en el inventario.");
                next; 
            }

            my $nuevo = Modelo::Suministro->new(
                $codigo, 
                $entries{"Nombre"}->get_text(),
                $entries{"Fabricante"}->get_text(), 
                $entries{"Precio Unitario"}->get_text(),
                $entries{"Cantidad"}->get_text(), 
                $entries{"Fecha Vencimiento"}->get_text(),
                $entries{"Nivel Mínimo"}->get_text()
            );
            
            $arbol->insertar($nuevo);
            $cb_refrescar->();
            last;
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