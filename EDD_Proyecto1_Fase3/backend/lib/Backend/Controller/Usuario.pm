package Backend::Controller::Usuario;
use Mojo::Base 'Mojolicious::Controller';
use Backend::Modelo::Usuario;

sub registrar {
    my $self = shift;

    my $params = $self->req->json;

    if (!$params) {
        return $self->render(json => {mensaje => "No se recibieron datos"}, status => 400);
    }

    my $nuevo_usuario = Backend::Modelo::Usuario->new(
        $params->{nombre_completo},
        $params->{tipo_usuario},
        $params->{numero_colegio},
        $params->{contrasena},
        $params->{departamento},
        $params->{especialidad}
    );

    $self->app->avl_usuarios->insertar($nuevo_usuario);
    $self->app->tabla_hash_personal->insertar($nuevo_usuario);

    return $self->render(json => {
        mensaje => "Usuario registrado exitosamente en AVL y Hash"
    }, status => 201);
}

sub login {
    my $self = shift;
    my $params = $self->req->json;

    if (!$params) {
        return $self->render(json => {mensaje => "Credenciales no recibidas"}, status => 400);
    }

    my $user_id  = $params->{username}; 
    my $password = $params->{password};

    my $nodo_encontrado = $self->app->avl_usuarios->buscar(undef, $user_id);

    if (defined $nodo_encontrado) {
        my $usuario = $nodo_encontrado->get_data();

        if ($usuario->get_password() eq $password) {
            return $self->render(json => {
                mensaje => "Login exitoso",
                tipo_usuario => $usuario->get_tipo(),
                username => $usuario->get_username()
            }, status => 200);
        } else {
            return $self->render(json => {mensaje => "Contraseña incorrecta"}, status => 401);
        }
    }

    return $self->render(json => {mensaje => "Usuario no encontrado"}, status => 404);
}

1;