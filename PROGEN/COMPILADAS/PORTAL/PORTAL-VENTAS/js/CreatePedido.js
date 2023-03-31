console.time("CrPedido");
function ConsClien() {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsClienGuar.php",
  })
    .done(function (data) {
      $(".lista_Clien").empty();
      $(".lista_Clien").append(data);
    })
    .fail(function () {
      // alert("Hubo un errror al cargar los Clientes");
    });
}

// ConsClien();

ajax_pro();
function ajax_pro() {
  if (window.localStorage) {
    if (
      window.localStorage.getItem("Maestro_productos") !== undefined &&
      window.localStorage.getItem("Maestro_productos")
    ) {
      var array = localStorage.getItem("Maestro_productos");
      // array = JSON.parse(array);
      // console.log('hello')

      if (
        window.localStorage.getItem("Lis_Prod") !== undefined &&
        window.localStorage.getItem("Lis_Prod")
      ) {
        // console.log('word')
        var Lis_prod = localStorage.getItem("Lis_Prod");
        // console.log(Lis_prod)
        $(".lista_prod").empty();
        $(".lista_prod").append(Lis_prod);
      } else {
        // console.log('.......')
        $.ajax({
          type: "POST",
          url: "../../controller/read/ConsProdGuar.php",
          data: { array: array },
        })
          .done(function (data) {
            data = data.split("??");
            // console.log(data[1]);
            localStorage.setItem("Lis_Prod", data[0]);
            $(".lista_prod").empty();
            $(".lista_prod").append(data[0]);
          })
          .fail(function () {
            // alert("Hubo un errror al cargar los productos");
          });
      }
    } else {
      MaestrosProductos();
    }
  }
}

CrearFila();

$(".LisProdIn").click(function () {
  console.log($(this).attr("id"));
});

try {
  function SelProd($id) {
    // Inactividad();
    try {
      $("#inputDescripcion" + $id + "").val();
      var item = $("#inputProducto" + $id + "").val();
      // console.log($id);

      if (item.length <= 0) {
        item = "NA";
      }

      inpute = "";

      // if ($("#" + item + "").length > 0) {
      //   console.log(item);
      //   var inpute = $("#" + item + "").text();
      // }
      codigo = inpute.split(" ");

      if (codigo[0].length > 0) {
        $("#inputProducto" + $id + "").val(codigo[0]);
        inpute = $.trim(inpute.replace(codigo[0], ""));
        // console.log(inpute);

        $("#inputDescripcion" + $id + "").val(inpute);
        $("#inputDescripcion" + $id + "").attr("title", inpute);

        ajaxValidad(item, $id, 1, item);
      } else {
        // ref cruzada
        var itemRe = item.substr(0, 25);
        itemRe = itemRe.replace(".", "");
        itemRe = itemRe + "-";
        itemRe = itemRe.replace(".", "");
        itemRe = itemRe.replace(".", "");
        itemRe = itemRe.replace(".", "");
        itemRe = itemRe.replace(".", "");
        itemRe = itemRe.replace(".", "");
        itemRe = itemRe.replace(".", "");
        itemRe = itemRe.replace("/", "-");
        itemRe = itemRe.replace("/", "-");
        itemRe = itemRe.replace("/", "-");
        itemRe = itemRe.replace("/", "-");
        itemRe = itemRe.replace("/", "-");
        itemRe = itemRe.replace("/", "-");
        itemRe = itemRe.replace("/", "-");

        // $("#inputProducto" + $id + "").val(inpute);
        // inpute=$.trim(inpute.replace(codigo[0],""))

        var inpute = $("#" + itemRe + "").text();

        $("#inputDescripcion" + $id + "").val(inpute);
        $("#inputDescripcion" + $id + "").attr("title", inpute);

        ajaxValidad(item, $id, 1, item);
      }
    } catch (error) {
      console.log(error);
    }
  }
} catch (error) {
  console.log("Error en la consulta del producto seleccionado");
}

function ajaxValidad(item, $id, $cont, RefCruz) {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsProdGuarDeta.php",
    data: { produc: item, refec: RefCruz },
  })
    .done(function (data) {
      //  console.log(data);
      data = data.split("??");
      precio = parseFloat(data[0]);
      Produc = data[2];
      /*
        Impuesto de Iva
      */
      CodImp = data[3];
      NomImp = data[4];
      PorImp = data[5];
      ProRef = data[6];
      Stock = data[7];
      Stock_Vis = data[8];
      if ($cont <= 100) {
        if (precio === 0) {
          ajaxValidad(Produc, $id, $cont + 1, ProRef);
        } else {
          if ($.trim($("#inputDescripcion" + $id + "").val()) != "") {
            descuento = data[1];
            //  console.log("data: " + data);
            //  console.log("precio: " + precio);
            // console.log("cont: " + $cont);
            // console.log("input: " + input);
            // console.log("descuento: " + descuento);

            // Impresion del Impuesto de Iva
            $("#CodImp" + $id + "").text(CodImp);
            $("#NomImp" + $id + "").text(NomImp);
            $("#PorImp" + $id + "").val(PorImp);
            $("#inputDescuento" + $id + "").val(descuento);
            $("#inputProducto" + $id + "").val();
            if (ProRef === Produc) {
              $("#inputProducto" + $id + "").val(Produc);
            } else {
              $("#inputProducto" + $id + "").val(ProRef);
            }

            $("#inputPrecio" + $id + "").val(
              new Intl.NumberFormat("es-CO").format(
                parseFloat(precio).toFixed(3)
              )
            );
            $("#inputPrecio" + $id + "-ori").val(precio);

            if (Stock > 0) {
              $("#stock" + $id + "").attr("src", "../../img/stocksi.png");
            } else {
              $("#stock" + $id + "").attr("src", "../../img/stockno.png");
            }

            if (Stock_Vis == 1) {
              $("#stock" + $id + "").attr("title", "Stock: " + Stock);
            }

            

            CalcuDesGene();
          }
          $("#inputPrecio" + $id + "").attr("disabled", "disabled");

          $("#inputPrecio" + $id + "-ori").attr("disabled", "disabled");
          $("#inputDescuento" + $id + "").attr("disabled", "disabled");
        }
      }
    })
    .fail(function () {
      // alert("Hubo un errror al cargar los precios");
    });
}

function guardarPedido() {
  SumaVal1 = 0;
  Sumaval2 = 0;

  $(".val-tot-ori").each(function () {
    SumaVal1 += parseFloat($(this).val());
  });

  $(".val-tot").each(function () {
    Sumaval2 += parseFloat($(this).val());
  });

  if (SumaVal1 > 0 && Sumaval2 > 0) {
    $("#coverScreen").show();

    Dire = $.trim($("#inputDireccion").val());
    Depa = $.trim($("#Departamento").val());
    Ciu = $.trim($("#Municipio").val());

    if (Dire > 0 || Dire != "") {
      if (Depa > 0 || Depa === "EX") {
        if (Ciu > 0) {
          const table = document.getElementById("tablaprueba");
          const rowCount = table.rows.length;
          Contador = 0;
          for (var vd = 1; vd <= rowCount + 1000; vd++) {
            if (Contador == rowCount) {
              break;
            }

            if ($("#inputProducto" + vd + "").length > 0) {
              produc = $("#inputProducto" + vd + "").val();
              RefCruz(vd, produc);

              SelProd(vd);

              Valid = ValiCamp(1, vd);
              if (Valid == 999) {
                break;
              }

              Valid2 = ValiCamp(2, vd);
              if (Valid2 == 999) {
                break;
              }

              Nature = $.trim($("#Modalidad").val());
              test = "0";
              if (Nature == "0300105" || Nature == "0300106") {
                test = "512";
              } else if (Nature == "0300107") {
                test = "513";
              } else if (Nature == "0300108") {
                test = "514";
              } else if (Nature == "0300102") {
                test = "800";
              } else if (Nature == "0300113" || Nature == "0300114") {
                test = "805";
              } else if (Nature == "0300104") {
                test = "515";
              } else {
                tes($("#inputProducto" + vd + "").val(), vd);

                // $.ajax({
                //   type: "POST",
                //   url: "../../controller/read/ConsProdInd",
                //   data: { Produc: $("#inputProducto" + vd + "").val(),vd:vd },
                // })
                //   .done(function (dat) {
                //     dat=dat.split("??");
                //     input =
                //       '<input id="inputTes' + dat[1] + '" value="' + dat[0] + '" type="hidden">';

                //     $("#tes").append(input);
                //   })
                //   .fail(function () {
                //     // alert("Hubo un errror al cargar las tes");
                //   });
              }

              Contador++;
            }
          }
          // var Con=0
          // var lim=1000
          // var incr=0
          // while ( incr<5000){
          //   incr++
          //   // console.log("no avanzo");

          //   console.log($("#inputTes1").val())
          //   if ($("#inputTes1").length > 0) {
          //     Con=1
          //   }
          // }
          if (Valid != 999 && Valid2 != 999) {
            var ItemsPed = {
              Product: null,
              SalesQuantity: null,
              Pordesc: null,
              // SalesPrice: null,
              // Value: null,
              InputTypeOutPut: null,
              Infoadicional: null,
            };
            try {
              console.time("CreatePed");

              if (
                window.localStorage.getItem("Client") !== undefined &&
                window.localStorage.getItem("Client")
              ) {
                $.ajax({
                  type: "POST",
                  url: "../../view/Cliente/Arch.php",
                }).done(function (data) {});
                var data = localStorage.getItem("Clien");

                console.timeEnd("CreatePed");
                InfoClien = data.split("¿?");
                // console.log(InfoClien);

                ValidarFraude = 1;
                //validación de cambio de descuento cuando no es vendedor,
                //al estar en 0 no retringe creación de pedido pero si restaura el valor del descuento al original
                //unicamente cuando es cliente, ya que el vendedor si lo puede modificar

                // console.log(InfoClien[8])
                // console.log($("#DesGene").val())
                // console.log(InfoClien[9])

                if (ValidarFraude == 0 && InfoClien[9] === "1") {
                  $("#DesGene").val(InfoClien[8]);
                }

                if (
                  InfoClien[8] === $("#DesGene").val() ||
                  (InfoClien[9] === "2" && ValidarFraude == 0)
                ) {
                  let CrePedVent = {
                    Client: InfoClien[0],
                    // Client: '',
                    Store: InfoClien[1],
                    Cliente: InfoClien[0],
                    // Cliente: $("#NumIdenTwo").val(),
                    DeliveryStore: InfoClien[3],
                    PaymentTerms: $("#inputCondicion").val(),
                    MessageForNote: $("#Descripcion").val(),
                    Nature: $("#Modalidad").val(),
                    Descuent: parseInt($("#DesGene").val()),
                    Usuario: InfoClien[10],
                    DireccionEnt: $("#inputDireccion").val(),
                    DepartamentonEnt: $("#Departamento").val(),
                    MunicipioEnt: $("#Municipio").val(),
                    Items: [],
                  };
                  Contador = 0;

                  for (var it = 1; it <= rowCount + 1000; it++) {
                    if (Contador == rowCount) {
                      break;
                    }
                    if ($("#inputProducto" + it + "").length > 0) {
                      // CalcuDesGene();
                      // total(it);
                      // TotFinal();

                      var ItemsPed = {
                        Product: null,
                        SalesQuantity: null,
                        Pordesc: null,
                        // SalesPrice: null,
                        // Value: null,
                        InputTypeOutPut: null,
                        Infoadicional: null,
                      };

                      Nature = $.trim($("#Modalidad").val());
                      test = "0";

                      if (Nature == "0300105" || Nature == "0300106") {
                        test = "512";
                      } else if (Nature == "0300107") {
                        test = "513";
                      } else if (Nature == "0300108") {
                        test = "514";
                      } else if (Nature == "0300102") {
                        test = "800";
                      } else if (Nature == "0300113" || Nature == "0300114") {
                        test = "805";
                      } else if (Nature == "0300118") {
                        test = "504";
                      } else if (Nature == "0300104") {
                        test = "515";
                      }

                      ItemsPed.Product = $("#inputProducto" + it + "").val();

                      ItemsPed.SalesQuantity = parseInt(
                        $("#inputCantidad" + it + "").val()
                      );

                      PorDes = $("#inputDescuento" + it + "").val();
                      if (PorDes == null) {
                        PorDes = 0;
                      }

                      ItemsPed.Pordesc = parseFloat(PorDes);
                      if (test === "0") {
                        test = $("#inputTes" + it + "").val();
                      }

                      if (test == undefined) {
                        test = "501";
                      }

                      ItemsPed.InputTypeOutPut = test;

                      ItemsPed.Infoadicional = $(
                        "#inputObservacion" + it + ""
                      ).val();

                      CrePedVent.Items.push(ItemsPed);

                      Contador++;
                    }
                  }

                  CrePedVent = JSON.stringify(CrePedVent);

                  console.log(CrePedVent);
                  try {
                    $.ajax({
                      type: "POST",
                      url: "../../controller/api/ws_verify_GuarPed.php",
                      data: { CrePedVent: CrePedVent },
                    }).done(function (data) {
                      $("#coverScreen").hide();

                      var P1 = data.search("creado");
                      var P2 = data.search("exito");
                      var P3 = data.search("No Pedido");

                      var P4 = data.search("error");
                      var P5 = data.search("500");

                      data = data.replace(
                        'errorCode":400,"errorMessage":"',
                        ""
                      );
                      data = data.replace('errorCode":500', "");
                      data = data.replace('"errorMessage":"', "");
                      data = data.replace('{"', "");
                      data = data.replace('"}', "");

                      if (P1 >= 0 && P2 >= 0 && P3 >= 0 && P4 < 0 && P5 < 0) {
                        if ($("#carrito").length > 0) {
                          localStorage.removeItem("Carrito-" + InfoClien[0]);
                        }

                        Swal.fire({
                          title: "Pedido Registrado!",
                          text: data,
                          icon: "success",
                          showCancelButton: true,
                          confirmButtonColor: "#0d6efd",
                          cancelButtonColor: "#28a745",
                          confirmButtonText: "Nuevo Pedido",
                          cancelButtonText: "Ver Pedidos",
                        }).then((result) => {
                          if (result.isConfirmed) {
                            location.href = "Crear_pedido";
                          } else {
                            location.href = "Consultar_Pedidos";
                          }
                        });
                      } else {
                        Swal.fire({
                          title: "Pedido Incompleto!",
                          text: data,
                          icon: "error",
                          confirmButtonColor: "#0d6efd",
                          confirmButtonText: "Validar",
                        }).then((result) => {});
                      }

                      // console.log(data)
                    });
                  } catch (error) {
                    $("#coverScreen").hide();
                    Swal.fire({
                      title: "¡Un error ha ocurrido!",
                      html:
                        error +
                        " <br> Se presenta error de conectividad, revisa tu conexiòn a la red. <br> si el problema persiste contacte al administrador",
                      icon: "warning",
                    }).then((result) => {});
                  }
                } else {
                  Swal.fire({
                    title: "Fraude detectado",
                    text: "El descuento no puede ser modificado, se informara al administrador",
                    icon: "error",
                  }).then(() => {
                    location.reload();
                  });
                }
              } else {
                $.ajax({
                  type: "POST",
                  url: "../../controller/read/LoadCliePed.php",
                })
                  .done(function (data) {
                    // console.timeEnd("CreatePed");
                    InfoClien = data.split("??");
                    // console.log(InfoClien);

                    ValidarFraude = 1;
                    //validación de cambio de descuento cuando no es vendedor,
                    //al estar en 0 no retringe creación de pedido pero si restaura el valor del descuento al original
                    //unicamente cuando es cliente, ya que el vendedor si lo puede modificar

                    // console.log(InfoClien[8])
                    // console.log($("#DesGene").val())
                    // console.log(InfoClien[9])

                    if (ValidarFraude == 0 && InfoClien[9] === "1") {
                      $("#DesGene").val(InfoClien[8]);
                    }

                    if (
                      InfoClien[8] === $("#DesGene").val() ||
                      (InfoClien[9] === "2" && ValidarFraude == 0)
                    ) {
                      let CrePedVent = {
                        Client: InfoClien[0],
                        // Client: '',
                        Store: InfoClien[1],
                        Cliente: InfoClien[0],
                        // Cliente: $("#NumIdenTwo").val(),
                        DeliveryStore: InfoClien[3],
                        PaymentTerms: $("#inputCondicion").val(),
                        MessageForNote: $("#Descripcion").val(),
                        Nature: $("#Modalidad").val(),
                        Descuent: parseInt($("#DesGene").val()),
                        Usuario: InfoClien[10],
                        DireccionEnt: $("#inputDireccion").val(),
                        DepartamentonEnt: $("#Departamento").val(),
                        MunicipioEnt: $("#Municipio").val(),
                        Items: [],
                      };
                      Contador = 0;

                      for (var it = 1; it <= rowCount + 1000; it++) {
                        if (Contador == rowCount) {
                          break;
                        }
                        if ($("#inputProducto" + it + "").length > 0) {
                          // CalcuDesGene();
                          // total(it);
                          // TotFinal();

                          var ItemsPed = {
                            Product: null,
                            SalesQuantity: null,
                            Pordesc: null,
                            // SalesPrice: null,
                            // Value: null,
                            InputTypeOutPut: null,
                            Infoadicional: null,
                          };

                          Nature = $.trim($("#Modalidad").val());
                          test = "0";

                          if (Nature == "0300105" || Nature == "0300106") {
                            test = "512";
                          } else if (Nature == "0300107") {
                            test = "513";
                          } else if (Nature == "0300108") {
                            test = "514";
                          } else if (Nature == "0300102") {
                            test = "800";
                          } else if (
                            Nature == "0300113" ||
                            Nature == "0300114"
                          ) {
                            test = "805";
                          } else if (Nature == "0300118") {
                            test = "504";
                          } else if (Nature == "0300104") {
                            test = "515";
                          }

                          ItemsPed.Product = $(
                            "#inputProducto" + it + ""
                          ).val();

                          ItemsPed.SalesQuantity = parseInt(
                            $("#inputCantidad" + it + "").val()
                          );

                          PorDes = $("#inputDescuento" + it + "").val();
                          if (PorDes == null) {
                            PorDes = 0;
                          }

                          ItemsPed.Pordesc = parseFloat(PorDes);
                          // ItemsPed.Pordesc = 0;

                          if (test === "0") {
                            test = $("#inputTes" + it + "").val();
                          }

                          if (test == undefined) {
                            test = "501";
                          }

                          if ($("#ARC_" + it + "").length > 0) {
                            test = $("#ARC_" + it + "").val();
                          }

                          ItemsPed.InputTypeOutPut = test;

                          ItemsPed.Infoadicional = $(
                            "#inputObservacion" + it + ""
                          ).val();

                          CrePedVent.Items.push(ItemsPed);

                          Contador++;
                        }
                      }

                      CrePedVent = JSON.stringify(CrePedVent);

                      console.log(CrePedVent);
                      $("#coverScreen").hide();
                      try {
                        $.ajax({
                          type: "POST",
                          url: "../../controller/api/ws_verify_GuarPed.php",
                          data: { CrePedVent: CrePedVent },
                        }).done(function (data) {
                          $("#coverScreen").hide();

                          var P1 = data.search("creado");
                          var P2 = data.search("exito");
                          var P3 = data.search("No Pedido");

                          var P4 = data.search("error");
                          var P5 = data.search("500");

                          data = data.replace(
                            'errorCode":400,"errorMessage":"',
                            ""
                          );
                          // data = data.replace('errorCode":500', "");
                          // data = data.replace('"errorMessage":"', "");
                          // data = data.replace('{"', "");
                          // data = data.replace('"}', "");

                          if (P5 >= 0) {
                            data =
                              "Se presento un error de comunicación con el servidor de destino, por favor intente nuevamente. si el error continua por favor contacte al administrador";
                          }

                          if (
                            P1 >= 0 &&
                            P2 >= 0 &&
                            P3 >= 0 &&
                            P4 < 0 &&
                            P5 < 0
                          ) {
                            if ($("#carrito").length > 0) {
                              localStorage.removeItem(
                                "Carrito-" + InfoClien[0]
                              );
                            }

                            Swal.fire({
                              title: "Pedido Registrado!",
                              text: data,
                              icon: "success",
                              showCancelButton: true,
                              confirmButtonColor: "#0d6efd",
                              cancelButtonColor: "#28a745",
                              confirmButtonText: "Nuevo Pedido",
                              cancelButtonText: "Ver Pedidos",
                            }).then((result) => {
                              if (result.isConfirmed) {
                                location.href = "Crear_pedido";
                              } else {
                                location.href = "Consultar_Pedidos";
                              }
                            });
                          } else {
                            Swal.fire({
                              title: "Pedido Incompleto!",
                              text: data,
                              icon: "error",
                              confirmButtonColor: "#0d6efd",
                              confirmButtonText: "Validar",
                            }).then((result) => {});
                          }

                          // console.log(data)
                        });
                      } catch (error) {
                        $("#coverScreen").hide();
                        Swal.fire({
                          title: "¡Un error ha ocurrido!",
                          html:
                            error +
                            " <br> Se presenta error de conectividad, revisa tu conexiòn a la red. <br> si el problema persiste contacte al administrador",
                          icon: "warning",
                        }).then((result) => {});
                      }
                    } else {
                      Swal.fire({
                        title: "Fraude detectado",
                        text: "El descuento no puede ser modificado, se informara al administrador",
                        icon: "error",
                      }).then(() => {
                        location.reload();
                      });
                    }
                  })
                  .fail(function () {
                    // alert("Hubo un errror al cargar el Cliente Final");
                  });
              }
            } catch (err) {
              $("#coverScreen").hide();
              Swal.fire({
                title: "¡Un error ha ocurrido!",
                html:
                  err +
                  " <br> Se presenta error de conectividad, revisa tu conexiòn a la red. <br> si el problema persiste contacte al administrador",
                icon: "warning",
              }).then((result) => {});
            }
          } else {
            $("#coverScreen").hide();
          }
        } else {
          Swal.fire({
            title: "Campos vacios",
            text: "Debe indicar un municipio de entrega",
            icon: "warning",
            confirmButtonColor: "#0d6efd",
            confirmButtonText: "Validar",
          }).then((result) => {
            $("#coverScreen").hide();
          });
        }
      } else {
        Swal.fire({
          title: "Campos vacios",
          text: "Debe Indicar un Departamento de entrega",
          icon: "warning",
          confirmButtonColor: "#0d6efd",
          confirmButtonText: "Validar",
        }).then((result) => {
          $("#coverScreen").hide();
        });
      }
    } else {
      Swal.fire({
        title: "Campos vacios",
        text: "Debe Indicar una Dirección de entrega",
        icon: "warning",
        confirmButtonColor: "#0d6efd",
        confirmButtonText: "Validar",
      }).then((result) => {
        $("#coverScreen").hide();
      });
    }
  } else {
    Swal.fire({
      title: "Items vacios",
      text: "Debe Indicar almenos un Item completo",
      icon: "warning",
      confirmButtonColor: "#0d6efd",
      confirmButtonText: "Validar",
    }).then((result) => {
      $("#coverScreen").hide();
    });
  }
}

function Inactividad() {
  // $.ajax({
  //   type: "POST",
  //   url: "../../controller/Create/Inactividad.php",
  // })
  //   .done(function () {})
  //   .fail(function () {});
}

function BorrarCarrito() {
  try {
    $.ajax({
      type: "POST",
      url: "../../controller/read/LoadCliePed.php",
    }).done(function (data) {
      InfoClien = data.split("??");
      localStorage.removeItem("Carrito-" + InfoClien[0]);
      location.href = "Crear_pedido";
    });
  } catch (error) {
    console.log(error);
  }
}

function RefCruz(rc, produc) {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsProdGuarDeta.php",
    data: { produc: produc },
  }).done(function (data) {
    data = data.split("??");
    Produc = $.trim(data[2]);
    ProdRefCruz = $.trim(data[6]);
    $("#inputProducto" + rc + "").val(Produc);
  });
}
//  console.timeEnd("CrPedido");

function tes(produc, id) {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsProdInd",
    data: { Produc: produc, vd: id },
  })
    .done(function (dat) {
      dat = dat.split("??");
      input =
        '<input id="inputTes' + id + '" value="' + dat[0] + '" type="hidden">';

      $("#tes").append(input);
    })
    .fail(function () {
      // alert("Hubo un errror al cargar las tes");
    });
}

$("#Modalidad").change(function () {
  const table = document.getElementById("tablaprueba");
  const rowCount = table.rows.length;
  Contador = 0;
  for (var vd = 1; vd <= rowCount + 1000; vd++) {
    if (Contador == rowCount) {
      break;
    }

    if ($("#inputProducto" + vd + "").length > 0) {
      total(vd);
      Contador++;
    }
  }

  // TotFinal();
});

$("#PDF").click(function () {
  console.log("Loading PDF...");
  Obs = $("#Descripcion").val();
  Dir = $("#inputDireccion").val();
  try {
    Swal.fire({
      title: "Cotización",
      text: "Generando PDF",
      icon: "success",
      timer: 5000,
    }).then((result) => {
      $("#coverScreen").hide();
    });
  } catch (error) {
    console.log("Error: " + error);
  }

  console.time("PDF");
  $.ajax({
    type: "POST",
    url: "../../controller/read/CabPdf.php",
    data: { Obs: Obs, Dir: Dir },
  }).done(function (data) {
    console.timeEnd("PDF");
    location.href = "pdfPedido.php";
  });
});

$("#Plantilla").on("click", function (event) {
  event.preventDefault();
  // resto de tu codigo

  window.open("plantilla.php");
});

function guardarCotizacion() {
  Swal.fire({
    title: "¡CONFIRMACIÓN!",
    text: "¿Desea guardar la cotización?",
    icon: "info",
    showCancelButton: true,
    confirmButtonColor: "#0d6efd",
    cancelButtonColor: "#28a745",
    confirmButtonText: "NO",
    cancelButtonText: "SI",
  }).then((result) => {
    if (result.isConfirmed) {
    } else {
      SumaVal1 = 0;
      Sumaval2 = 0;

      $(".val-tot-ori").each(function () {
        SumaVal1 += parseFloat($(this).val());
        // console.log(SumaVal1);
      });

      $(".val-tot").each(function () {
        Sumaval2 += parseFloat($(this).val());
        // console.log(Sumaval2);
      });

      if (SumaVal1 > 0 && Sumaval2 > 0) {
        $("#coverScreen").show();

        Dire = $.trim($("#inputDireccion").val());
        Depa = $.trim($("#Departamento").val());
        Ciu = $.trim($("#Municipio").val());

        if (Dire > 0 || Dire != "") {
          if (Depa > 0 || Depa === "EX") {
            if (Ciu > 0) {
              var ItemsPed = {
                Product: null,
                SalesQuantity: null,
                Infoadicional: null,
              };
              try {
                let CrePedVent = {
                  Client: "99999999",
                  MessageForNote: $("#Descripcion").val(),
                  Date: "01/01/9999",
                  Usuario: "User-999",
                  DireccionEnt: $("#inputDireccion").val(),
                  DepartamentonEnt: $("#Departamento").val(),
                  MunicipioEnt: $("#Municipio").val(),
                  Items: [],
                };
                Contador = 0;
                const table = document.getElementById("tablaprueba");
                const rowCount = table.rows.length;

                for (var it = 1; it <= rowCount + 1000; it++) {
                  if (Contador == rowCount) {
                    break;
                  }
                  if ($("#inputProducto" + it + "").length > 0) {
                    var ItemsPed = {
                      clien: null,
                      Producto: null,
                      Cantidad: null,
                      Observacion: null,
                    };
                    ItemsPed.clien = "99999999";
                    ItemsPed.Producto = $("#inputProducto" + it + "").val();

                    ItemsPed.Cantidad = parseInt(
                      $("#inputCantidad" + it + "").val()
                    );

                    ItemsPed.Observacion = $(
                      "#inputObservacion" + it + ""
                    ).val();

                    CrePedVent.Items.push(ItemsPed);

                    Contador++;
                  }
                }

                CrePedVent = JSON.stringify(CrePedVent);

                // console.log(CrePedVent);
                try {
                  $.ajax({
                    type: "POST",
                    url: "../../controller/create/NewCotiz.php",
                    data: { CrePedVent: CrePedVent },
                  }).done(function (data) {
                    $("#coverScreen").hide();
                    dat = data.split("#");
                    Obs = $("#Descripcion").val();
                    Dir = $("#inputDireccion").val();

                    Swal.fire({
                      title: "Cotización Registrada!",
                      text: data,
                      icon: "success",
                      showCancelButton: true,
                      confirmButtonColor: "#0d6efd",
                      cancelButtonColor: "#28a745",
                      confirmButtonText: "Ver PDF",
                      cancelButtonText: "Continuar",
                    }).then((result) => {
                      if (result.isConfirmed) {
                        // location.href = "Crear_pedido";
                        FunCoti(dat[1], 2, 909, Obs, Dir);
                      } else {
                        // location.href = "Consultar_Pedidos";
                        console.log();
                      }
                    });

                    // console.log(data)
                  });
                } catch (error) {
                  $("#coverScreen").hide();
                  Swal.fire({
                    title: "¡Un error ha ocurrido!",
                    html:
                      error +
                      " <br> Se presenta error de conectividad, revisa tu conexiòn a la red. <br> si el problema persiste contacte al administrador",
                    icon: "warning",
                  }).then((result) => {});
                }
              } catch (err) {
                $("#coverScreen").hide();
                Swal.fire({
                  title: "¡Un error ha ocurrido!",
                  html:
                    err +
                    " <br> Se presenta error de conectividad, revisa tu conexiòn a la red. <br> si el problema persiste contacte al administrador",
                  icon: "warning",
                }).then((result) => {});
              }
            } else {
              Swal.fire({
                title: "Campos vacios",
                text: "Debe indicar un municipio de entrega",
                icon: "warning",
                confirmButtonColor: "#0d6efd",
                confirmButtonText: "Validar",
              }).then((result) => {
                $("#coverScreen").hide();
              });
            }
          } else {
            Swal.fire({
              title: "Campos vacios",
              text: "Debe Indicar un Departamento de entrega",
              icon: "warning",
              confirmButtonColor: "#0d6efd",
              confirmButtonText: "Validar",
            }).then((result) => {
              $("#coverScreen").hide();
            });
          }
        } else {
          Swal.fire({
            title: "Campos vacios",
            text: "Debe Indicar una Dirección de entrega",
            icon: "warning",
            confirmButtonColor: "#0d6efd",
            confirmButtonText: "Validar",
          }).then((result) => {
            $("#coverScreen").hide();
          });
        }
      } else {
        Swal.fire({
          title: "Items vacios",
          text: "Debe Indicar almenos un Item completo",
          icon: "warning",
          confirmButtonColor: "#0d6efd",
          confirmButtonText: "Validar",
        }).then((result) => {
          $("#coverScreen").hide();
        });
      }
    }
  });
}
