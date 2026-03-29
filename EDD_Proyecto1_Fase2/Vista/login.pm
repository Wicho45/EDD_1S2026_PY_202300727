package Vista::login;

use strict;
use warnings;
use Gtk3 -init;
use utf8;

use Vista::signin;
use constant signin => 'Vista::signin';
use Vista::admin;
use constant admin => 'Vista::admin';
use Vista::user;
use constant user => 'Vista::user';

sub mostrar_login {
    my ($class, $arbol_usuarios, $lista_proveedores, $lista_medicamentos, $arbol_equipo, $arbol_suministros) = @_;

    my $dialog = Gtk3::Dialog->new(
        'Login - EDD Medtrack', 
        undef, 
        ['modal'],
        'Iniciar sesión'   => 'accept',
        'Cerrar'           => 'cancel',
        'Registrar usuario'=> 100,
        'Datos'            => 200
    );

    $dialog->set_position('center');
    $dialog->set_default_size(300, -1);

    my $content = $dialog->get_content_area();
    $content->set_spacing(10);
    $content->set_border_width(15);

    my $ruta_logo = "imagenes/logo.png"; 
    if (-e $ruta_logo) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file_at_scale($ruta_logo, 120, 120, 1);
        my $logo = Gtk3::Image->new_from_pixbuf($pixbuf);
        $content->pack_start($logo, 0, 0, 10);
    }

    my $label_usuario = Gtk3::Label->new("Usuario:");
    $label_usuario->set_xalign(0);
    my $entry_usuario = Gtk3::Entry->new();

    my $label_contrasena = Gtk3::Label->new("Contraseña:");
    $label_contrasena->set_xalign(0);
    my $entry_contrasena = Gtk3::Entry->new();
    $entry_contrasena->set_placeholder_text("**********");
    $entry_contrasena->set_visibility(0);

    $content->pack_start($label_usuario, 0, 0, 0);
    $content->pack_start($entry_usuario, 0, 0, 5);
    $content->pack_start($label_contrasena, 0, 0, 0);
    $content->pack_start($entry_contrasena, 0, 0, 5);

    $dialog->signal_connect(response => sub {
        my ($dialog, $response) = @_;

        if ($response eq 'accept') {

            my $user_actual = $entry_usuario->get_text();
            my $pass_actual = $entry_contrasena->get_text();

            if ($user_actual eq "" || $pass_actual eq "") {
                mostrar_mensaje($dialog, 'error', "Error", "Debe llenar todos los campos.");
                return;
            }

            if ($user_actual eq "admin" && $pass_actual eq "admin") {

                mostrar_mensaje($dialog, 'info', "Bienvenido", "Login exitoso");

                $dialog->hide();

                my $v_admin = admin->mostrar_admin($arbol_usuarios, $user_actual, $lista_proveedores, $lista_medicamentos, $arbol_equipo, $arbol_suministros);

                $v_admin->signal_connect(destroy => sub {
                    $entry_usuario->set_text("");
                    $entry_contrasena->set_text("");
                    $dialog->show_all();
                });

                return;
            }

            my $usuario_encontrado = $arbol_usuarios->buscar($user_actual, undef);

            if (!defined $usuario_encontrado) {
                mostrar_mensaje($dialog, 'error', "Error", "Usuario no encontrado.");
                return;
            }

            if ($usuario_encontrado->get_data()->get_password() ne $pass_actual) {
                mostrar_mensaje($dialog, 'error', "Error", "Contraseña incorrecta.");
                return;
            }

            $dialog->hide();

            if ($usuario_encontrado->get_data()->get_tipo() == 5) {
                my $v_admin = admin->mostrar_admin($arbol_usuarios, $user_actual, $lista_proveedores, $lista_medicamentos, $arbol_equipo, $arbol_suministros);

                $v_admin->signal_connect(destroy => sub {
                    $dialog->show();
                });

            } else {
                user->mostrar_user();
                $dialog->show();
            }

        }
        elsif ($response eq '100') {
            my $dialog_signin = signin->mostrar_signin($arbol_usuarios, $dialog);

            # Hacer que signin sea hijo del login
            $dialog_signin->set_transient_for($dialog);
            $dialog_signin->set_modal(1);

        }
        elsif ($response eq '200') {
            mostrar_mensaje($dialog, 'info', "Datos", "Nombre: Luis Cornelio Marroquín López\nCarné: 202300727\nCurso: Estructuras de datos\nSección: A");
        }
        else {
            Gtk3->main_quit;
        }
    });

    $dialog->show_all();

    Gtk3->main;
}

sub mostrar_mensaje {
    my ($parent, $tipo, $titulo, $texto) = @_;
    my $m = Gtk3::MessageDialog->new($parent, 'modal', $tipo, 'ok', $texto);
    $m->set_title($titulo);
    $m->run();
    $m->destroy();
}

1;