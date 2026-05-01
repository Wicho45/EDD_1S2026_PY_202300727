package Backend::Controlador::cargaMasiva;

use strict;
use warnings;
use JSON;
use utf8;
use Gtk3;

use Backend::Controlador::bst;
use constant bst => 'Backend::Controlador::bst';
use Backend::Controlador::avl;
use constant avl => 'Backend::Controlador::avl';
use Modelo::Usuario;
use constant Usuario => 'Modelo::Usuario';
use Modelo::Proveedor;
use constant Proveedor => 'Modelo::Proveedor';
use Modelo::Medicamento;
use constant Medicamento => 'Modelo::Medicamento';
use Modelo::Equipo;
use constant Equipo => 'Modelo::Equipo';
use Modelo::Suministro;
use constant Suministro => 'Modelo::Suministro';

sub carga_masiva {
    my ($class, $ruta, $arbol_usuarios, $lista_proveedores, $lista_medicamentos, $arbol_equipo, $arbol_suministros, $matriz_dispersa) = @_;

    open(my $fh, '<:raw', $ruta) or die "No se pudo abrir el archivo: $!";
    my $json_bytes = do { local $/; <$fh> };
    close($fh);

    my $data;
    eval {
        $data = decode_json($json_bytes);
    };
    if ($@) {
        return (0, "Error en el formato JSON o codificación: $@");
    }

    if (exists $data->{usuarios}) {
        return _procesar_usuarios($data->{usuarios}, $arbol_usuarios);
    } 
    elsif (exists $data->{proveedor}) {
        return _procesar_proveedores($data->{proveedor}, $lista_proveedores, $lista_medicamentos, $arbol_equipo, $arbol_suministros, $matriz_dispersa);
    } 
    else {
        return (0, "Formato de archivo no reconocido.");
    }
}

sub _procesar_usuarios {
    my ($lista, $arbol_usuarios) = @_;
    my $conteo = 0;

    foreach my $u (@$lista) {
        if (!$arbol_usuarios->buscar(undef, $u->{numero_colegio})) {
            my ($tipo_num) = $u->{tipo_usuario} =~ /(\d+)/;
            $tipo_num = int($tipo_num || 0);

            my $nuevo_usuario = Modelo::Usuario->new(
                $u->{nombre_completo},    
                $tipo_num,                
                $u->{numero_colegio},     
                $u->{contrasena},         
                $u->{departamento},       
                $u->{especialidad} // ""
            );

            $arbol_usuarios->insertar($nuevo_usuario);
            $conteo++;
        }
    }
    return (1, "Se cargaron $conteo nuevos usuarios exitosamente.");
}

sub _procesar_proveedores {
    my ($lista_json, $lista_circular_proveedores, $lista_doble_medicamentos, $arbol_bst_equipo, $arbol_b_suministros, $matriz) = @_;
    my $prov_cont = 0;
    my $prod_cont = 0;

    foreach my $p (@$lista_json) {
        my $nombre_proveedor = $p->{nombre}; 

        my $nuevo_proveedor = Modelo::Proveedor->new(
            $p->{nit}, 
            $nombre_proveedor, 
            "No especificado", 
            $p->{telefono}, 
            $p->{direccion}
        );

        if (defined $p->{fecha_entrega}) {
            $nuevo_proveedor->get_historial()->insertar($p->{fecha_entrega});
        }

        foreach my $e (@{$p->{entrega}}) {
            my $codigo = $e->{codigo} // "N/A";
            my $fabricante = $e->{fabricante} // "Desconocido";
            my $cantidad = $e->{cantidad} // 0;
            
            if ($cantidad <= 0 || ($e->{precio_unitario} // 0) <= 0) {
                next;
            }

            if (defined $matriz) {
                $matriz->insertar_o_sumar($nombre_proveedor, $fabricante, $cantidad);
            }

            my $tipo = $e->{tipo};
            
            if ($tipo eq "MEDICAMENTO") {
                my $med = Modelo::Medicamento->new(
                    $e->{codigo}, $e->{nombre}, $e->{principio_activo} // "N/A",
                    $fabricante, $cantidad, $e->{fecha_vencimiento},
                    $e->{precio_unitario}, $e->{nivel_minimo}
                );
                $lista_doble_medicamentos->insertar($med); 

            } elsif ($tipo eq "EQUIPO") {
                my $equipo = Modelo::Equipo->new(
                    $e->{codigo}, $e->{nombre}, $fabricante,
                    $e->{precio_unitario}, $cantidad, $e->{fecha_ingreso},
                    $e->{nivel_minimo}
                );
                $arbol_bst_equipo->insertar($equipo);

            } elsif ($tipo eq "SUMINISTRO") {
                my $sum = Modelo::Suministro->new(
                    $e->{codigo}, $e->{nombre}, $fabricante,
                    $e->{precio_unitario}, $cantidad, $e->{fecha_vencimiento},
                    $e->{nivel_minimo}
                );
                $arbol_b_suministros->insertar($sum);
            }
            $prod_cont++;
        }

        $lista_circular_proveedores->insertar($nuevo_proveedor);
        $prov_cont++;
    }

    return (1, "Carga masiva completada: $prov_cont proveedores y $prod_cont productos.");
}

1;