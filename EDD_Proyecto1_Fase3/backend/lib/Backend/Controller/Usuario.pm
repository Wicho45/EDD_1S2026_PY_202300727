package Backend::Controller::Usuario;


use Mojo::Base 'Mojolicious::Controller';
use Backend::Modelo::Usuario;
use Backend::Controlador::cargaMasiva;

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

sub procesar_carga {
    my $self = shift;
    my $json_data = $self->req->json;

    if (!$json_data) {
        return $self->render(json => { mensaje => "No se recibió información JSON" }, status => 400);
    }

    my ($exito, $mensaje) = Backend::Controlador::cargaMasiva->procesar_carga_web($json_data, $self->app);

    if ($exito) {
        return $self->render(json => { mensaje => $mensaje }, status => 200);
    } else {
        return $self->render(json => { mensaje => $mensaje }, status => 500);
    }
}

sub listar_personal {
    my $self = shift;

    my $lista_objetos = $self->app->avl_usuarios->obtener_todos(); 

    my @data_json;
    foreach my $u (@$lista_objetos) {
        push @data_json, {
            numero_colegio => $u->get_numero_colegio(),
            username       => $u->get_username(),
            tipo           => $u->get_tipo(),
            especialidad   => $u->get_especialidad(),
            departamento   => $u->get_departamento(),
        };
    }

    return $self->render(json => \@data_json);
}

1;