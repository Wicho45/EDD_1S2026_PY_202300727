package Controlador::RegistraMedicamento;

use strict;
use warnings;

use Modelo::Medicamento;
use constant Medicamento => 'Modelo::Medicamento';

sub registrarMedicamento {
    my ($class, $lista_inventario) = @_;
    my $continuar = "s";

    while ($continuar eq "s") {
        my $codigo_medicamento = generarNuevoCodigo($lista_inventario);

        print "\n--- Registro de Medicamento ($codigo_medicamento) ---\n";
        print "\nNombre comercial: "; my $nombre = <STDIN>; chomp $nombre;
        print "\nPrincipio activo: "; my $principio = <STDIN>; chomp $principio;
        print "\nLaboratorio: "; my $laboratorio = <STDIN>; chomp $laboratorio;
        print "\nStock: "; my $stock = <STDIN>; chomp $stock;
        print "\nVencimiento: "; my $vence = <STDIN>; chomp $vence;
        print "\nPrecio: "; my $precio = <STDIN>; chomp $precio;
        print "\nNivel reorden: "; my $reorden = <STDIN>; chomp $reorden;

        my $nuevo = Medicamento->new($codigo_medicamento, $nombre, $principio, $laboratorio, $stock, $vence, $precio, $reorden);

        $lista_inventario->insertar($nuevo);
        print "\nMedicina registrada exitosamente.\n";

        print "\n¿Desea registrar otro? (s/n): ";
        $continuar = <STDIN>; 
        chomp $continuar;
    }
    return 1;
}


sub cargaMasiva {
    my ($class, $lista_inventario, $ruta_archivo) = @_;
    open(my $fh, '<', $ruta_archivo) or die "No se puede abrir: $!";
    
    <$fh>; 
    
    while (my $linea = <$fh>) {
        chomp $linea;
        my @datos = split(',', $linea);
        
        eval {
            my $nuevo_med = Medicamento->new(@datos);
            $lista_inventario->insertar($nuevo_med);
        };
        if ($@) {
            warn "Línea omitida: $@"; 
        }
    }
    print "\nCarga masiva completada.\n";
    close($fh);
}


sub generarNuevoCodigo{
    my ($lista_inventario) = @_;
    
    return "MED001" if ($lista_inventario->is_empty());

    my $actual = $lista_inventario->{cabeza};
    while (defined($actual->get_next())) {
        $actual = $actual->get_next();
    }

    my ($numero) = $actual->get_data()->get_codigo_medicamento() =~ /(\d+)/;
    
    return sprintf("MED%03d", $numero + 1);
}

1;