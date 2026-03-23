package Controlador::RegistraMedicamento;

use strict;
use warnings;

use Modelo::Medicamento;
use constant Medicamento => 'Modelo::Medicamento';

use Reportes::ReporteListaDoblemente;
use constant ReporteListaDoblemente => 'Reportes::ReporteListaDoblemente';

use Reportes::ReporteMatriz;
use constant ReporteMatriz => 'Reportes::ReporteMatriz';

sub registrarMedicamento {
    my ($class, $lista_inventario, $matriz, $mapa_meds, $mapa_labs) = @_;
    my $continuar = "s";

    while ($continuar eq "s") {
        my $codigo_medicamento = generarNuevoCodigo($lista_inventario);

        print "\n--- Registro de Medicamento ($codigo_medicamento) ---\n";
        print "Nombre comercial: "; my $nombre = <STDIN>; chomp $nombre;
        print "Principio activo: "; my $principio = <STDIN>; chomp $principio;
        print "Laboratorio: "; my $laboratorio = <STDIN>; chomp $laboratorio;
        print "Stock: "; my $stock = <STDIN>; chomp $stock;
        print "Vencimiento: "; my $vence = <STDIN>; chomp $vence;
        print "Precio: "; my $precio = <STDIN>; chomp $precio;
        print "Nivel reorden: "; my $reorden = <STDIN>; chomp $reorden;

        my $nuevo = Medicamento->new($codigo_medicamento, $nombre, $principio, $laboratorio, $stock, $vence, $precio, $reorden);

        my $res = $lista_inventario->insertar($nuevo);
        ReporteListaDoblemente->generar_reporte($lista_inventario);
        print "\nInventario: $res\n";

        my $fila_idx = obtener_o_crear_indice($mapa_meds, $nombre);
        my $col_idx  = obtener_o_crear_indice($mapa_labs, $laboratorio);

        $matriz->insertar($fila_idx, $col_idx, $nuevo);
        ReporteMatriz->generar_reporte($matriz, $mapa_meds, $mapa_labs);
        print "Matriz Dispersa: [INSERT] ($fila_idx, $col_idx) con exito.\n";

        print "\n¿Desea registrar otro? (s/n): ";
        $continuar = <STDIN>; 
        chomp $continuar;
    }
    return 1;
}

sub cargaMasiva {
    my ($class, $lista_inventario, $matriz, $mapa_meds, $mapa_labs, $ruta_archivo) = @_;
    
    open(my $fh, '<', $ruta_archivo) or die "No se puede abrir el archivo: $!";
    <$fh>; 

    while (my $linea = <$fh>) {
        chomp $linea;
        my @datos = split(',', $linea);
        
        eval {
            my $nuevo_med = Medicamento->new(
                $datos[0], 
                $datos[1], 
                $datos[2], 
                $datos[3], 
                $datos[5], 
                $datos[6], 
                $datos[4], 
                $datos[7]  
            );
            
            $lista_inventario->insertar($nuevo_med);
            ReporteListaDoblemente->generar_reporte($lista_inventario);

            my $f_idx = obtener_o_crear_indice($mapa_meds, $nuevo_med->get_nombre_comercial());
            my $c_idx = obtener_o_crear_indice($mapa_labs, $nuevo_med->get_laboratorio_fabricante());
            $matriz->insertar($f_idx, $c_idx, $nuevo_med);
            ReporteMatriz->generar_reporte($matriz, $mapa_meds, $mapa_labs);
        };
        if ($@) {
            warn "Linea con error omitida: $@"; 
        }
    }
    print "\nCarga masiva procesada en todas las estructuras.\n";
    close($fh);
}

sub obtener_o_crear_indice {
    my ($lista, $nombre_buscado) = @_;
    my $actual = $lista->{head};
    my $contador = 0;

    while (defined $actual) {
        if (lc($actual->get_data()) eq lc($nombre_buscado)) {
            return $contador;
        }
        $actual = $actual->get_next();
        $contador++;
    }

    $lista->agregar_final($nombre_buscado);
    return $contador;
}

sub generarNuevoCodigo {
    my ($lista_inventario) = @_;
    return "MED001" if ($lista_inventario->is_empty());

    my $actual = $lista_inventario->{head};
    while (defined($actual->get_next())) {
        $actual = $actual->get_next();
    }

    my ($numero) = $actual->get_data()->get_codigo_medicamento() =~ /(\d+)/;
    return sprintf("MED%03d", $numero + 1);
}

1;