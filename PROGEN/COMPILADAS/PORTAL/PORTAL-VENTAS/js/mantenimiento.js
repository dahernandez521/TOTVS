function mantenimeinto(url){
    
    Swal.fire({
        title: "Mantenimiento",
        text: "En este momento se esta realizando mantenimiento en el servidor, le recomendamos intentar nuevamente mas tarde.",
        icon: "info",
        timer: 7000,
      }).then(() => {
        location.href = url;
      });
}