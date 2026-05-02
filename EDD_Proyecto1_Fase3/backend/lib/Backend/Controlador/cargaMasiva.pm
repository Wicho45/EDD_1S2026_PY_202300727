package Backend::Controlador::cargaMasiva;

use strict;
use warnings;
use utf8;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use Backend::Modelo::Usuario;
use Backend::Modelo::Proveedor;
use Backend::Modelo::Medicamento;
use Backend::Modelo::Equipo;
use Backend::Modelo::Suministro;
use Backend::Modelo::Relacion; # Importamos el modelo de relaciones

sub procesar_carga_web {
    my ($class, $data, $app_ctx) = @_;

    # Si el JSON principal es un arreglo, sabemos que es el archivo de relaciones
    if (ref($data) eq 'ARRAY') {
        return _procesar_relaciones($data, $app_ctx);
    } 
    elsif (exists $data->{usuarios}) {
        return _procesar_usuarios($data->{usuarios}, $app_ctx);
    } 
    elsif (exists $data->{proveedor}) {
        return _procesar_proveedores($data->{proveedor}, $app_ctx);
    } 
    else {
        return (0, "Formato de archivo no reconocido.");
    }
}

sub _procesar_usuarios {
    my ($lista, $ctx) = @_;
    my $conteo = 0;

    foreach my $u (@$lista) {
        if (!$ctx->avl_usuarios->buscar(undef, $u->{numero_colegio})) {
            
            my ($tipo_num) = $u->{tipo_usuario} =~ /(\d+)/;
            $tipo_num = int($tipo_num || 0);

            my $nuevo_usuario = Backend::Modelo::Usuario->new(
                $u->{nombre_completo},    
                $u->{tipo_usuario},
                $u->{numero_colegio},     
                $u->{contrasena},         
                $u->{departamento},       
                $u->{especialidad} // ""
            );

            $ctx->avl_usuarios->insertar($nuevo_usuario);        
            $ctx->tabla_hash_personal->insertar($nuevo_usuario); 
            
            # Verificación de seguridad: si el grafo existe en Backend.pm, agregamos el vértice
            if ($ctx->can('grafo_colaboracion') && defined $ctx->grafo_colaboracion) {
                $ctx->grafo_colaboracion->agregar_vertice($u->{numero_colegio}, $nuevo_usuario);
            }
            
            $conteo++;
        }
    }
    return (1, "Se cargaron $conteo nuevos usuarios exitosamente.");
}

sub _procesar_relaciones {
    my ($lista, $ctx) = @_;
    my $activas = 0;
    my $pendientes = 0;

    if (!$ctx->can('grafo_colaboracion') || !defined $ctx->grafo_colaboracion) {
        return (0, "Error del servidor: El Grafo de Colaboración no está inicializado en Backend.pm");
    }

    foreach my $r (@$lista) {
        my $solicitante = $r->{solicitante};
        my $receptor    = $r->{receptor};
        my $estado      = $r->{estado} // "";

        if ($estado eq "ACTIVA") {
            # Las activas van directo al grafo como aristas
            my $res = $ctx->grafo_colaboracion->agregar_arista($solicitante, $receptor, $estado);
            if ($res) {
                $activas++;
            }
        } 
        elsif ($estado eq "PENDIENTE") {
            # Las pendientes van al usuario receptor
            my $nodo_receptor = $ctx->avl_usuarios->buscar(undef, $receptor);
            if ($nodo_receptor) {
                my $obj_relacion = Backend::Modelo::Relacion->new($solicitante, $receptor, $estado);
                
                # Verificamos que el usuario tenga el método para recibir la solicitud para evitar caídas
                if ($nodo_receptor->get_data()->can('agregar_solicitud')) {
                    $nodo_receptor->get_data()->agregar_solicitud($obj_relacion);
                    $pendientes++;
                } else {
                    print "Advertencia: El modelo Usuario no tiene el método 'agregar_solicitud'\n";
                }
            }
        }
    }
    return (1, "Carga de Relaciones: $activas activas (Grafo) y $pendientes pendientes.");
}

sub _procesar_proveedores {
    my ($lista_json, $ctx) = @_;
    my $prov_cont = 0;
    my $prod_cont = 0;

    foreach my $p (@$lista_json) {
        my $nombre_prov = $p->{nombre}; 

        my $nuevo_prov = Backend::Modelo::Proveedor->new(
            $p->{nit}, $nombre_prov, "No especificado", 
            $p->{telefono}, $p->{direccion}
        );

        if (defined $p->{fecha_entrega}) {
            $nuevo_prov->get_historial()->insertar($p->{fecha_entrega});
        }

        foreach my $e (@{$p->{entrega}}) {
            my $fabricante = $e->{fabricante} // "Desconocido";
            my $cantidad = $e->{cantidad} // 0;
            
            if ($cantidad <= 0 || ($e->{precio_unitario} // 0) <= 0) { next; }

            if (defined $ctx->matriz_proveedores) {
                $ctx->matriz_proveedores->insertar_o_sumar($nombre_prov, $fabricante, $cantidad);
            }

            my $tipo = $e->{tipo};
            
            if ($tipo eq "MEDICAMENTO") {
                my $med = Backend::Modelo::Medicamento->new(
                    $e->{codigo}, $e->{nombre}, $e->{principio_activo} // "N/A",
                    $fabricante, $cantidad, $e->{fecha_vencimiento},
                    $e->{precio_unitario}, $e->{nivel_minimo}
                );
                $ctx->lista_medicamentos->insertar($med); 

            } elsif ($tipo eq "EQUIPO") {
                my $equipo = Backend::Modelo::Equipo->new(
                    $e->{codigo}, $e->{nombre}, $fabricante,
                    $e->{precio_unitario}, $cantidad, $e->{fecha_ingreso},
                    $e->{nivel_minimo}
                );
                $ctx->arbol_equipo->insertar($equipo);

            } elsif ($tipo eq "SUMINISTRO") {
                my $sum = Backend::Modelo::Suministro->new(
                    $e->{codigo}, $e->{nombre}, $fabricante,
                    $e->{precio_unitario}, $cantidad, $e->{fecha_vencimiento},
                    $e->{nivel_minimo}
                );
                $ctx->arbol_suministros->insertar($sum);
            }
            $prod_cont++;
        }

        $ctx->lista_proveedores->insertar($nuevo_prov);
        $prov_cont++;
    }

    return (1, "Carga masiva: $prov_cont proveedores y $prod_cont productos.");
}

1;