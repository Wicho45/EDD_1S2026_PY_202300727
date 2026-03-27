package Vista::signin;

use strict;
use warnings;
use Gtk3;
use utf8;
binmode(STDOUT, ":encoding(UTF-8)");

use Modelo::Usuario;
use constant Usuario => 'Modelo::Usuario';

sub mostrar_signin {
    my ($class, $arbol_usuarios) = @_;
    my $dialog = Gtk3::Dialog->new(
        'Signin - EDD Medtrack', 
        undef, 
        ['modal'],
        'Registrar'   => 'accept',
        'Regresar' => 'cancel',
    );

    $dialog->set_position('center');
    $dialog->set_default_size(300, -1);

    my $content = $dialog->get_content_area();
    $content->set_spacing(10);
    $content->set_border_width(15);

    ## Logo de usac
    my $ruta_logo = "imagenes/logo.png"; 
    if (-e $ruta_logo) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file_at_scale($ruta_logo, 120, 120, 1);
        my $logo = Gtk3::Image->new_from_pixbuf($pixbuf);
        $content->pack_start($logo, 0, 0, 10);
    } else {
        my $lbl_placeholder = Gtk3::Label->new("LOGOTIPO");
        $content->pack_start($lbl_placeholder, 0, 0, 10);
    }


    ## nombre usuario, tipo de usuario, numero de colegio, contrasena, departamento, especialidad
    ## Ingreso de nombre de usuario
    my $label_user = Gtk3::Label->new("Nombre de Usuario:");
    $label_user->set_xalign(0);
    my $entry_user = Gtk3::Entry->new();

    ##numero de colegio para usuarios
    my $label_num_colegio = Gtk3::Label->new("Número de Colegio:");
    $label_num_colegio->set_xalign(0);
    my $entry_num_colegio = Gtk3::Entry->new();

    ## comboBox con tipo de usuario
    my $label_tipo = Gtk3::Label->new("Tipo de personal:");
    $label_tipo->set_xalign(0);
    
    my $combo = Gtk3::ComboBoxText->new();
    $combo->append_text("Tipo"); 
    $combo->append_text("TIPO-01 - Médico General");
    $combo->append_text("TIPO-02 - Médico Especialista / Cirujano");
    $combo->append_text("TIPO-03 - Enfermero/a");
    $combo->append_text("TIPO-04 - Técnico de Laboratorio");
    
    $combo->set_active(0);

    ## ComboBox para departamento
    my $label_departamento = Gtk3::Label->new("Departamento:");
    $label_departamento->set_xalign(0);

    my $combo_departamento = Gtk3::ComboBoxText->new();
    $combo_departamento->append_text("Seleccione un departamento...");
    $combo_departamento->set_active(0);

    $combo->signal_connect(changed => sub {
        my $active_index = $combo->get_active();

        $combo_departamento->remove_all();

        if ($active_index == 1) {
            $combo_departamento->append_text("Medicina general y consulta externa");
        }
        elsif ($active_index == 2) {
            $combo_departamento->append_text("Cirugía y quirofanos");
        }
        elsif ($active_index == 3) {
            $combo_departamento->append_text("Medicina general y consulta externa");
            $combo_departamento->append_text("Cirugía y quirofanos");
            $combo_departamento->append_text("Farmacia hospitalaria");
        }
        elsif ($active_index == 4) {
            $combo_departamento->append_text("Laboratorio clínico");
        }

        $combo_departamento->set_active(0);
    });

    ## Ingreso de especialidad
    my $label_especialidad = Gtk3::Label->new("Especialidad:");
    $label_especialidad->set_xalign(0);
    my $entry_especialidad = Gtk3::Entry->new();

    ##Ingreso de contrasena
    my $label_pass1 = Gtk3::Label->new("Contraseña (mínimo 6 caracteres):");
    $label_pass1->set_xalign(0);
    my $entry_pass1 = Gtk3::Entry->new();
    $entry_pass1->set_visibility(0);

    ##Ingreso de confirmacion de contrasena
    my $label_pass2 = Gtk3::Label->new("Confirmar Contraseña:");
    $label_pass2->set_xalign(0);
    my $entry_pass2 = Gtk3::Entry->new();
    $entry_pass2->set_visibility(0);

    ## Entrada de usuario
    $content->pack_start($label_user, 0, 0, 0);
    $content->pack_start($entry_user, 0, 0, 5);
    ## Entrada de número de colegio
    $content->pack_start($label_num_colegio, 0, 0, 0);
    $content->pack_start($entry_num_colegio, 0, 0, 5);
    ## ComboBox para tipo de usuario
    $content->pack_start($label_tipo, 0, 0, 0);
    $content->pack_start($combo, 0, 0, 5);
    ## ComboBox para departamento
    $content->pack_start($label_departamento, 0, 0, 0);
    $content->pack_start($combo_departamento, 0, 0, 5);
    ## Ingreso de especialidad
    $content->pack_start($label_especialidad, 0, 0, 0);
    $content->pack_start($entry_especialidad, 0, 0, 5);
    ## Ingreso de contraseña
    $content->pack_start($label_pass1, 0, 0, 0);
    $content->pack_start($entry_pass1, 0, 0, 5);
    $content->pack_start($label_pass2, 0, 0, 0);
    $content->pack_start($entry_pass2, 0, 0, 5);

    $dialog->show_all();

    ## bucle para registro de usuarios
    while (1) {
        my $response = $dialog->run();

        if ($response eq 'accept') {
            my $username = $entry_user->get_text();
            my $tipo = $combo->get_active();
            my $departamento = undef;
            my $especialidad = $entry_especialidad->get_text();
            my $num_colegio = $entry_num_colegio->get_text();
            my $password1 = $entry_pass1->get_text();
            my $password2 = $entry_pass2->get_text();

            ## Validar campos
            if (length($username) == 0 || length($password1) == 0 || length($password2) == 0 || $tipo == 0 || length($num_colegio) == 0 || $combo_departamento->get_active() == -1) {
                mostrar_mensaje($dialog, 'error', "Error", "Debe llenar todos los campos y seleccionar un departamento.");
                next;
            }

            ##validar numero de colegio
            if (!verificar_numero_colegio($dialog, $num_colegio)) {
                next;
            }

            ##validar especialidad no este vacia para tipo 1 y 2 
            if ($tipo == 1 || $tipo == 2){
                print "llegue a la condicion\n";
                if (length($especialidad) == 0) {
                    mostrar_mensaje($dialog, 'error', "Error", "Debe llenar la especialidad.");
                    next;
                }
            }

            if ($password1 ne $password2) { ## Validar que las contraseñas coincidan
                mostrar_mensaje($dialog, 'error', "Error", "Las contraseñas no coinciden.");
                next;
            }

            if (length($password1) < 6) { ## Validar longitud de contraseña
                mostrar_mensaje($dialog, 'error', "Error", "La contraseña debe tener al menos 6 caracteres.");
                next;
            }

            if($arbol_usuarios->buscar($username, $num_colegio)){ ## Validar si el usuario o número de colegio ya existe
                mostrar_mensaje($dialog, 'error', "Error", "El usuario o número de colegio ya existe.");
                next;
            }

            my $departamento_actual = $combo_departamento->get_active_text();
            $departamento = obtener_departamento($departamento_actual);

            ## Crear y guardar nuevo usuario
            my $nuevo_usuario = Usuario->new($username, $tipo, $num_colegio, $password1, $departamento, $especialidad);
            $arbol_usuarios->insertar($nuevo_usuario);
            print "Usuario registrado: " . $nuevo_usuario->get_username() . ", Tipo: " . $nuevo_usuario->get_tipo() . ", Colegio: " . $nuevo_usuario->get_numero_colegio() . ", Departamento: " . $nuevo_usuario->get_departamento() . ", Especialidad: " . $nuevo_usuario->get_especialidad() . "\n";
            mostrar_mensaje($dialog, 'info', "Éxito", "Usuario registrado exitosamente.");
        }else{
            print "Error\n";
            last;
        }
    }

    $dialog->destroy();

}

sub mostrar_mensaje {
    my ($parent, $tipo, $titulo, $texto) = @_;
    my $m = Gtk3::MessageDialog->new($parent, 'modal', $tipo, 'ok', $texto);
    $m->set_title($titulo);
    $m->run();
    $m->destroy();
}

sub verificar_numero_colegio {
    my ($parent, $numero_colegio) = @_;

    if ($numero_colegio !~ /^COL-\d{5}$/) {
        mostrar_mensaje($parent, 'error', "Error", "El número de colegio debe tener el formato COL-XXXXX.");
        return 0;
    }
    return 1;
}

sub obtener_departamento {
    my ($actual) = @_;

    return "DEP-MED" if $actual eq "Medicina general y consulta externa";
    return "DEP-CIR" if $actual eq "Cirugía y quirofanos";
    return "DEP-LAB" if $actual eq "Laboratorio clínico";
    return "DEP-FAR" if $actual eq "Farmacia hospitalaria";

}

1;