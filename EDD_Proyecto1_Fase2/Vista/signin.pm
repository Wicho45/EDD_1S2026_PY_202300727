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


    ## nombre usuario, tipo de usuario, numero de colegio, contrasena
    ## Ingreso de nombre de usuario
    my $label_user = Gtk3::Label->new("Nombre de Usuario:");
    $label_user->set_xalign(0);
    my $entry_user = Gtk3::Entry->new();

    ##nuero de colegio para usuarios
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
    $combo->append_text("TIPO-05 - Personal Administrativo (ADMIN)");
    
    $combo->set_active(0);

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

    $content->pack_start($label_user, 0, 0, 0);
    $content->pack_start($entry_user, 0, 0, 5);
    $content->pack_start($label_num_colegio, 0, 0, 0);
    $content->pack_start($entry_num_colegio, 0, 0, 5);
    $content->pack_start($label_tipo, 0, 0, 0);
    $content->pack_start($combo, 0, 0, 5);
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
            my $tipo = $combo->get_active_text();
            my $num_colegio = $entry_num_colegio->get_text();
            my $password1 = $entry_pass1->get_text();
            my $password2 = $entry_pass2->get_text();

            if (length($username) == 0 || length($password1) == 0 || length($password2) == 0 || $tipo eq "Tipo") {
                mostrar_mensaje($dialog, 'error', "Error", "Debe llenar todos los campos.");
                next;
            }

            if ($password1 ne $password2) {
                mostrar_mensaje($dialog, 'error', "Error", "Las contraseñas no coinciden.");
                next;
            }

            if (length($password1) < 6) {
                mostrar_mensaje($dialog, 'error', "Error", "La contraseña debe tener al menos 6 caracteres.");
                next;
            }

            my $nuevo_usuario = Usuario->new($username, $tipo, $num_colegio, $password1);
            $arbol_usuarios->insertar($nuevo_usuario);
            print "Usuario registrado: " . $nuevo_usuario->get_username() . ", Tipo: " . $nuevo_usuario->get_tipo() . ", Colegio: " . $nuevo_usuario->get_numero_colegio() . "\n";
            mostrar_mensaje($dialog, 'info', "Éxito", "Usuario registrado exitosamente.");
        }else{
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

1;