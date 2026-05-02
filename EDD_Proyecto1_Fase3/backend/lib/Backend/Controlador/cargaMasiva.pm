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

sub procesar_carga_web {
    my ($class, $data, $app_ctx) = @_;

    if (exists $data->{usuarios}) {
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
            
            $conteo++;
        }
    }
    return (1, "Se cargaron $conteo nuevos usuarios exitosamente.");
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