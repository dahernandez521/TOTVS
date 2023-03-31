function espera() {
  Swal.fire({
    title: "Cargue en Proceso",
    text: "Se esta realizando el cargue de los productos, por favor espera un momento",
    icon: "info",
    timer: 4000,
  }).then(() => {
    location.reload();
  });
}
