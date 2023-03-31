 console.time("Modalidades");
// console.timeEnd("t1");
if (window.localStorage) {
  if (
    window.localStorage.getItem("Modalidades") !== undefined &&
    window.localStorage.getItem("Modalidades")
  ) {
    // var array = localStorage.getItem("Modalidades");

    // $.ajax({
    //   type: "POST",
    //   url: "../../controller/read/Modalidades.php",
    //   data: { array: array },
    // })
    //   .done(function (data) {

    //   })
    //   .fail(function () {
    //     alert("Hubo un errror al cargar las modalidades");
    //   });
  } else {
    CreateModalidades();
  }
}

function CreateModalidades() {
  $.ajax({
    type: "POST",
    url: "../../controller/read/Modalidades.php",
  })
    .done(function (data) {
      // console.timeEnd("Modalidades");
      localStorage.setItem("Modalidades", data);
    })
    .fail(function () {
      alert("Hubo un errror al cargar las Modalidades");
    });
}


