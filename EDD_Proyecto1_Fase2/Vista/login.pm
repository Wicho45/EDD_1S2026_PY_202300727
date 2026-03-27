package Vista::login;

use strict;
use warnings;
use Gtk3;
use utf8;
binmode(STDOUT, ":encoding(UTF-8)");

use Vista::signin;
use constant signin => 'Vista::signin';
use Vista::admin;
use constant admin => 'Vista::admin';
use Vista::user;
use constant user => 'Vista::user';

sub mostrar_login {
    my ($class, $arbol_usuarios) = @_;
    my $autenticado = 0;
    my $dialog = Gtk3::Dialog->new(
        'Login - EDD Medtrack', 
        undef, 
        ['modal'],
        'Iniciar sesion'   => 'accept',
        'Cerrar' => 'cancel',
        'Registrar usuario' => 100,
        'Datos' => 200
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

    ## ingreso de usuario
    my $label_usuario = Gtk3::Label->new("Usuario:");
    $label_usuario->set_xalign(0);
    my $entry_usuario = Gtk3::Entry->new();


    ## ingreso de contrasena
    my $label_contrasena = Gtk3::Label->new("Contraseña:");
    $label_contrasena->set_xalign(0);
    my $entry_contrasena = Gtk3::Entry->new();
    $entry_contrasena->set_visibility(0); 
    $entry_contrasena->set_placeholder_text("**********");

    $content->pack_start($label_usuario, 0, 0, 0);
    $content->pack_start($entry_usuario, 0, 0, 5);
    $content->pack_start($label_contrasena, 0, 0, 0);
    $content->pack_start($entry_contrasena, 0, 0, 5);
    
    $dialog->show_all();
    ## bucle para inicio de sesion o registro
    while (1) {
        my $response = $dialog->run();

        if ($response eq 'accept') { ## Validar inicio de sesion
            my $user_actual = $entry_usuario->get_text();
            my $pass_actual = $entry_contrasena->get_text();

            if (length($user_actual) == 0 || length($pass_actual) == 0) {
                mostrar_mensaje($dialog, 'error', "Error", "Debe llenar todos los campos.");
                next;
            }

            ## admin quemado 
            if ($user_actual eq "admin" && $pass_actual eq "admin" ){
                $dialog->hide();
                mostrar_mensaje($dialog, 'info', "Bienvenido ", "¡Login exitoso! Bienvenido admin" );
                admin->mostrar_admin();
                $dialog->show();
                next;
            }

            my $usuario_encontrado = $arbol_usuarios->buscar($user_actual, undef);
            if (!defined($usuario_encontrado)) {
                mostrar_mensaje($dialog, 'error', "Error", "Usuario no encontrado.");
                next;
            }
            elsif ($usuario_encontrado->get_data()->get_password() ne $pass_actual) {
                mostrar_mensaje($dialog, 'error', "Error", "Contraseña incorrecta.");
                next;
            }else{
                ## Validar tipo de usuario
                if($usuario_encontrado->get_data()->get_tipo() == 5 ){ 
                    $dialog->hide();
                    mostrar_mensaje($dialog, 'info', "Bienvenido ", "¡Login exitoso! Bienvenido, " . $usuario_encontrado->get_data()->get_username() . ".");
                    admin->mostrar_admin();
                    $dialog->show();
                }else{
                    $dialog->hide();
                    mostrar_mensaje($dialog, 'info', "Bienvenido ", "¡Login exitoso! Bienvenido, " . $usuario_encontrado->get_data()->get_username() . ".");
                    user->mostrar_user();
                    $dialog->show();
                }
                next;
            }

        } 
        elsif ($response eq '100') { ## Mostrar registro de usuarios
            $dialog->hide();
            signin->mostrar_signin($arbol_usuarios);
            $dialog->show();
        }
        elsif ($response eq '200'){ ## Mostrar datos del estudiante
            mostrar_mensaje($dialog, 'info', "Datos del estudiantes", "Nombre: Luis Cornelio Marroquín López\nCarné: 202300727\nCurso: Estructuras de datos\nSección: A");
        }
        else {
            last; 
        }
    }
    
    $dialog->destroy();
    return $autenticado;
}

sub mostrar_mensaje {
    my ($parent, $tipo, $titulo, $texto) = @_;
    my $m = Gtk3::MessageDialog->new($parent, 'modal', $tipo, 'ok', $texto);
    $m->set_position('center');
    $m->set_title($titulo);
    $m->run();
    $m->destroy();
}

1;