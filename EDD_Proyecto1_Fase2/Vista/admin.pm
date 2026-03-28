package Vista::admin;

use strict;
use warnings;
use Gtk3;
use utf8;

sub mostrar_admin {
    my ($class, $arbol_usuarios, $usuario_actual, $lista_proveedores, $lista_medicamentos, $arbol_equipo) = @_;

    my $window = Gtk3::Window->new('toplevel');
    $window->set_title("Panel de Administración - Medtrack");
    $window->set_default_size(800, 500);
    $window->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 10);
    $vbox->set_border_width(10);
    $window->add($vbox);

    # Logo
    my $ruta_logo = "imagenes/logo.png"; 
    if (-e $ruta_logo) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file_at_scale($ruta_logo, 120, 120, 1);
        my $logo = Gtk3::Image->new_from_pixbuf($pixbuf);
        $vbox->pack_start($logo, 0, 0, 10);
    }

    # Bienvenida
    my $lbl_admin = Gtk3::Label->new();
    $lbl_admin->set_markup("<span size='x-large'><b>Bienvenido, $usuario_actual</b></span>");
    $lbl_admin->set_halign('center');
    $vbox->pack_start($lbl_admin, 0, 0, 10);

    # Título tabla
    my $label_titulo = Gtk3::Label->new();
    $label_titulo->set_markup("<span size='large' weight='bold'>Personal Registrado</span>");
    $vbox->pack_start($label_titulo, 0, 0, 5);

    # Modelo
    my $model = Gtk3::ListStore->new(
        'Glib::String', 'Glib::String', 'Glib::String',
        'Glib::String', 'Glib::String'
    );

    llenar_tabla_desde_avl($model, $arbol_usuarios);

    my $treeview = Gtk3::TreeView->new_with_model($model);

    my @titulos = ("No. Colegio", "Nombre Completo", "Tipo", "Especialidad", "Departamento");
    for my $i (0 .. $#titulos) {
        my $renderer = Gtk3::CellRendererText->new();
        my $column = Gtk3::TreeViewColumn->new_with_attributes($titulos[$i], $renderer, text => $i);
        $column->set_resizable(1);
        $column->set_sort_column_id($i);
        $treeview->append_column($column);
    }

    my $scroll = Gtk3::ScrolledWindow->new(undef, undef);
    $scroll->set_policy('automatic', 'automatic');
    $scroll->add($treeview);
    $vbox->pack_start($scroll, 1, 1, 0);

    # --- Contenedor para botones inferiores ---
    my $hbox_botones = Gtk3::Box->new('horizontal', 10);
    $hbox_botones->set_halign('center'); 
    $vbox->pack_start($hbox_botones, 0, 0, 5);

    ## boton para carga masiva
    my $btn_nuevo = Gtk3::Button->new_with_label("Carga Masiva");
    $btn_nuevo->signal_connect(clicked => sub {
        print "Hiciste clic en el nuevo botón\n";
    });
    $hbox_botones->pack_start($btn_nuevo, 0, 0, 5);

    ##boton para reportes
    my $btn_reporte = Gtk3::Button->new_with_label("Reportes");
    $btn_reporte->signal_connect(clicked => sub {
        print "Hiciste clic en el botón de reportes\n";
    });
    $hbox_botones->pack_start($btn_reporte, 0, 0, 5);

    ##boton para recorridos
    my $btn_recorrido = Gtk3::Button->new_with_label("Recorridos");
    $btn_recorrido->signal_connect(clicked => sub {
        print "Hiciste clic en el botón de recorridos\n";
    });
    $hbox_botones->pack_start($btn_recorrido, 0, 0, 5);

    # boton para cerrar sesion
    my $btn_cerrar = Gtk3::Button->new_with_label("Cerrar Sesión");
    $btn_cerrar->signal_connect(clicked => sub {
        $window->destroy();
    });
    $hbox_botones->pack_start($btn_cerrar, 0, 0, 5);
    
    $window->signal_connect(destroy => sub {
    });

    $window->show_all();

    return $window;
}

sub llenar_tabla_desde_avl {
    my ($model, $arbol) = @_;
    return if $arbol->is_empty();
    _recorrido_tabla_rec($model, $arbol->{root});
}

sub _recorrido_tabla_rec {
    my ($model, $nodo) = @_;
    return unless defined($nodo);

    _recorrido_tabla_rec($model, $nodo->get_left());

    my $u = $nodo->get_data();
    my $iter = $model->append();

    $model->set($iter,
        0 => $u->get_numero_colegio(),
        1 => $u->get_username(),
        2 => _formatear_tipo($u->get_tipo()),
        3 => $u->get_especialidad() || "N/A",
        4 => $u->get_departamento(),
    );

    _recorrido_tabla_rec($model, $nodo->get_right());
}

sub _formatear_tipo {
    my $t = shift;
    my %tipos = (
        1 => "Médico Gral.",
        2 => "Especialista",
        3 => "Enfermería",
        4 => "Técnico"
    );
    return $tipos{$t} // "Otro";
}

1;