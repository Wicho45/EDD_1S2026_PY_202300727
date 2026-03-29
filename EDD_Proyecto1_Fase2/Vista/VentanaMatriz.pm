package Vista::VentanaMatriz;

use strict;
use warnings;
use Gtk3;
use utf8;
use Reportes::ReporteMatriz;

sub mostrar_matriz {
    my ($class, $matriz_dispersa) = @_;

    my $window = Gtk3::Window->new('toplevel');
    $window->set_title("Matriz Dispersa: Proveedores vs Fabricantes");
    $window->set_default_size(1000, 700);
    $window->set_position('center');

    my $vbox = Gtk3::Box->new('vertical', 15);
    $vbox->set_border_width(15);
    $window->add($vbox);

    my $label = Gtk3::Label->new();
    $label->set_markup("<span size='x-large' weight='bold'>Visualización de Matriz Dispersa</span>");
    $vbox->pack_start($label, 0, 0, 0);

    # Generamos el archivo antes de intentar cargarlo
    Reportes::ReporteMatriz->generar_reporte($matriz_dispersa);

    my $scroll = Gtk3::ScrolledWindow->new(undef, undef);
    $scroll->set_policy('automatic', 'automatic');
    $vbox->pack_start($scroll, 1, 1, 0);

    # Ruta alineada con tu carpeta de imágenes
    my $ruta_img = "Imagenes/matriz_proveedores.png";

    if (-e $ruta_img) {
        my $image = Gtk3::Image->new_from_file($ruta_img);
        $scroll->add_with_viewport($image);
    } else {
        my $lbl_error = Gtk3::Label->new("No se encontró la imagen en $ruta_img.\nAsegúrese de que la carga masiva tenga datos.");
        $scroll->add($lbl_error);
    }

    my $btn_regresar = Gtk3::Button->new_with_label("Regresar");
    $btn_regresar->set_size_request(100, 40);
    $vbox->pack_start($btn_regresar, 0, 0, 5);

    $btn_regresar->signal_connect(clicked => sub { $window->destroy(); });

    $window->show_all();
    return $window;
}

1;