package Vista::admin;

use strict;
use warnings;
use Gtk3;
use utf8;
use JSON;

use Controlador::cargaMasiva;
use constant cargaMasiva => 'Controlador::cargaMasiva';
use Vista::GestionEquipo;
use Vista::GestionSuministros;
use Vista::GestionPersonal;
use Vista::VentanaMatriz;

sub mostrar_admin {
    my ($class, $arbol_usuarios, $usuario_actual, $lista_proveedores, $lista_medicamentos, $arbol_equipo, $arbol_suministros, $matriz_proveedores_fabricantes) = @_;

    my $window = Gtk3::Window->new('toplevel');
    $window->set_title("Panel de Administración - Medtrack");
    $window->set_default_size(950, 600);
    $window->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 10);
    $vbox->set_border_width(10);
    $window->add($vbox);

    # Logo
    my $ruta_logo = "imagenes/logo.png"; 
    if (-e $ruta_logo) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file_at_scale($ruta_logo, 100, 100, 1);
        my $logo = Gtk3::Image->new_from_pixbuf($pixbuf);
        $vbox->pack_start($logo, 0, 0, 5);
    }

    # Bienvenida
    my $lbl_admin = Gtk3::Label->new();
    $lbl_admin->set_markup("<span size='x-large'><b>Bienvenido, $usuario_actual</b></span>");
    $lbl_admin->set_halign('center');
    $vbox->pack_start($lbl_admin, 0, 0, 10);

    # Contenedor superior para filtros
    my $hbox_filtros = Gtk3::Box->new('horizontal', 10);
    $vbox->pack_start($hbox_filtros, 0, 0, 5);

    # Título tabla
    my $label_titulo = Gtk3::Label->new();
    $label_titulo->set_markup("<span size='large' weight='bold'>Personal Registrado</span>");
    $hbox_filtros->pack_start($label_titulo, 0, 0, 5);

    # Espaciador
    my $spacer = Gtk3::Box->new('horizontal', 0);
    $hbox_filtros->pack_start($spacer, 1, 1, 0);

    # Combo de Categoría
    my $cb_categoria = Gtk3::ComboBoxText->new();
    $cb_categoria->append_text("Todos");
    $cb_categoria->append_text("Departamento");
    $cb_categoria->append_text("Especialidad");
    $cb_categoria->append_text("Nivel Autorización");
    $cb_categoria->set_active(0);
    $hbox_filtros->pack_start($cb_categoria, 0, 0, 5);

    # Combo de Valores (Dinámico)
    my $cb_valores = Gtk3::ComboBoxText->new();
    $cb_valores->set_sensitive(0);
    $hbox_filtros->pack_start($cb_valores, 0, 0, 5);

    my $btn_aplicar = Gtk3::Button->new_with_label("Aplicar Filtro");
    $hbox_filtros->pack_start($btn_aplicar, 0, 0, 5);

    # Modelo
    my $model = Gtk3::ListStore->new(
        'Glib::String', 'Glib::String', 'Glib::String',
        'Glib::String', 'Glib::String'
    );

    $cb_categoria->signal_connect(changed => sub {
        my $opcion = $cb_categoria->get_active_text();
        $cb_valores->remove_all();
        if ($opcion eq "Todos") {
            $cb_valores->set_sensitive(0);
        } else {
            $cb_valores->set_sensitive(1);
            my %unicos;
            _extraer_opciones_recursivo($arbol_usuarios->{root}, $opcion, \%unicos);
            foreach my $val (sort keys %unicos) {
                $cb_valores->append_text($val);
            }
            $cb_valores->set_active(0);
        }
    });

    $btn_aplicar->signal_connect(clicked => sub {
        my $cat = $cb_categoria->get_active_text();
        my $val = $cb_valores->get_active_text();
        $model->clear();
        if ($cat eq "Todos" || !defined($val)) {
            llenar_tabla_desde_avl($model, $arbol_usuarios);
        } else {
            _llenar_tabla_filtrada($model, $arbol_usuarios->{root}, $cat, $val);
        }
    });

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
    $vbox->pack_start($hbox_botones, 0, 0, 10);

    # contenedor 2 para botones inferiores
    my $hbox_botones_2 = Gtk3::Box->new('horizontal', 10);
    $hbox_botones_2->set_halign('center'); 
    $vbox->pack_start($hbox_botones_2, 0, 0, 10);

    ## boton para carga masiva
    my $btn_nuevo = Gtk3::Button->new_with_label("Carga Masiva");
    $btn_nuevo->signal_connect(clicked => sub {
        my $file_chooser = Gtk3::FileChooserDialog->new(
            "Seleccionar Archivo JSON", $window, 'open',
            'gtk-cancel' => 'cancel', 'gtk-open' => 'accept'
        );
        my $filtro = Gtk3::FileFilter->new();
        $filtro->set_name("Archivos JSON");
        $filtro->add_pattern("*.json");
        $file_chooser->add_filter($filtro);
        if ($file_chooser->run() eq 'accept') {
            my $filename = $file_chooser->get_filename();
            my ($exito, $mensaje) = Controlador::cargaMasiva->carga_masiva(
                $filename, $arbol_usuarios, $lista_proveedores, 
                $lista_medicamentos, $arbol_equipo, $arbol_suministros, $matriz_proveedores_fabricantes
            );
            my $dialog_msg = Gtk3::MessageDialog->new($window, 'modal', ($exito ? 'info' : 'error'), 'ok', $mensaje);
            $dialog_msg->run(); $dialog_msg->destroy();
            if ($exito) {
                $model->clear(); 
                llenar_tabla_desde_avl($model, $arbol_usuarios); 
            }
        }
        $file_chooser->destroy();
    });
    $hbox_botones->pack_start($btn_nuevo, 0, 0, 5);

    # boton para Gestionar Equipos
    my $btn_equipo = Gtk3::Button->new_with_label("Gestionar Equipos");
    $btn_equipo->signal_connect(clicked => sub {
        Vista::GestionEquipo->mostrar_gestion($arbol_equipo);
    });
    $hbox_botones->pack_start($btn_equipo, 0, 0, 5);

    # boton para Gestionar Suministros
    my $btn_suministros = Gtk3::Button->new_with_label("Gestionar Suministros");
    $btn_suministros->signal_connect(clicked => sub {
        Vista::GestionSuministros->mostrar_gestion($arbol_suministros);
    });
    $hbox_botones->pack_start($btn_suministros, 0, 0, 5);

    # boton para gestionar Personal medico
    my $btn_personal = Gtk3::Button->new_with_label("Gestionar Personal Medico");
    $btn_personal->signal_connect(clicked => sub {
    my $v_gestion = Vista::GestionPersonal->mostrar_gestion($arbol_usuarios);
    
        $v_gestion->signal_connect(destroy => sub {
            $model->clear();
            llenar_tabla_desde_avl($model, $arbol_usuarios);
        });
    });
    $hbox_botones->pack_start($btn_personal, 0, 0, 5);

    # boton para registrar usuarios
    my $btn_registrar = Gtk3::Button->new_with_label("Registrar Usuarios");
    $btn_registrar->signal_connect(clicked => sub {
        my $dialog_signin = Vista::signin->mostrar_signin($arbol_usuarios, $window);
        
        $dialog_signin->signal_connect(destroy => sub {
            $model->clear();
            llenar_tabla_desde_avl($model, $arbol_usuarios);
        });
    });
    $hbox_botones->pack_start($btn_registrar, 0, 0, 0);

    ## boton para ver matriz
    my $btn_matriz = Gtk3::Button->new_with_label("Matriz Proveedores-Fabricantes");
    $btn_matriz->signal_connect(clicked => sub {
        Vista::VentanaMatriz->mostrar_matriz($matriz_proveedores_fabricantes);
    });
    $hbox_botones_2->pack_start($btn_matriz, 0, 0, 5);

    ## boton para reportes
    my $btn_reporte = Gtk3::Button->new_with_label("Reportes");
    $hbox_botones_2->pack_start($btn_reporte, 0, 0, 5);

    ## boton para recorridos
    my $btn_recorrido = Gtk3::Button->new_with_label("Recorridos");
    $hbox_botones_2->pack_start($btn_recorrido, 0, 0, 5);

    # boton para cerrar sesion
    my $btn_cerrar = Gtk3::Button->new_with_label("Cerrar Sesión");
    $btn_cerrar->signal_connect(clicked => sub { $window->destroy(); });
    $hbox_botones_2->pack_start($btn_cerrar, 0, 0, 5);

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
    _agregar_fila_modelo($model, $nodo->get_data());
    _recorrido_tabla_rec($model, $nodo->get_right());
}

sub _extraer_opciones_recursivo {
    my ($nodo, $criterio, $hash_ref) = @_;
    return unless defined($nodo);
    my $u = $nodo->get_data();
    if ($criterio eq "Departamento") {
        $hash_ref->{$u->get_departamento()} = 1;
    } elsif ($criterio eq "Especialidad") {
        my $esp = $u->get_especialidad();
        $hash_ref->{$esp} = 1 if defined($esp) && $esp ne "";
    } elsif ($criterio eq "Nivel Autorización") {
        $hash_ref->{_formatear_tipo($u->get_tipo())} = 1;
    }
    _extraer_opciones_recursivo($nodo->get_left(), $criterio, $hash_ref);
    _extraer_opciones_recursivo($nodo->get_right(), $criterio, $hash_ref);
}

sub _llenar_tabla_filtrada {
    my ($model, $nodo, $criterio, $valor) = @_;
    return unless defined($nodo);
    _llenar_tabla_filtrada($model, $nodo->get_left(), $criterio, $valor);
    my $u = $nodo->get_data();
    my $match = 0;
    if ($criterio eq "Departamento") {
        $match = 1 if $u->get_departamento() eq $valor;
    } elsif ($criterio eq "Especialidad") {
        $match = 1 if ($u->get_especialidad() // "") eq $valor;
    } elsif ($criterio eq "Nivel Autorización") {
        $match = 1 if _formatear_tipo($u->get_tipo()) eq $valor;
    }
    _agregar_fila_modelo($model, $u) if $match;
    _llenar_tabla_filtrada($model, $nodo->get_right(), $criterio, $valor);
}

sub _agregar_fila_modelo {
    my ($model, $u) = @_;
    my $iter = $model->append();
    $model->set($iter,
        0 => $u->get_numero_colegio(),
        1 => $u->get_username(),
        2 => _formatear_tipo($u->get_tipo()),
        3 => $u->get_especialidad() || "N/A",
        4 => $u->get_departamento(),
    );
}

sub _formatear_tipo {
    my $t = shift;
    my %tipos = (1 => "Médico Gral.", 2 => "Especialista", 3 => "Enfermería", 4 => "Técnico");
    return $tipos{$t} // "Otro";
}

1;