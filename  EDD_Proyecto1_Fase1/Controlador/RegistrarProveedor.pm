package Controlador::RegistrarProveedor;

use strict;
use warnings;

use Modelo::Proveedor;
use constant Proveedor => 'Modelo::Proveedor';

use Reportes::ReporteCircular;
use constant ReporteCircular => 'Reportes::ReporteCircular';

sub registrarProveedor {

    my ($class, $lista_proveedores) = @_;
    my $continuar = "s";

    while ($continuar eq "s") {

        print "\nIngrese el NIT : ";
        my $nit = <STDIN>;
        chomp $nit;

        print "\nIngrese el nombre de la empresa: ";
        my $nombre_empresa = <STDIN>;
        chomp $nombre_empresa;

        print "\nIngrese el nombre del contacto principal: ";
        my $contacto_principal = <STDIN>;
        chomp $contacto_principal;

        print "\nIngrese el telefono: ";
        my $telefono = <STDIN>;
        chomp $telefono;

        print "\nIngrese la direccion: ";
        my $direccion = <STDIN>;
        chomp $direccion;

        my $nuevo = Proveedor->new($nit, $nombre_empresa, $contacto_principal, $telefono, $direccion);

        $lista_proveedores->insertar($nuevo);
        ReporteCircular->generar_reporte($lista_proveedores);
        print "\nProveedor registrada exitosamente.\n";

        print "\n¿Desea registrar otro? (s/n): ";
        $continuar = <STDIN>; 
        chomp $continuar;
    }
    return 1;
}

1;