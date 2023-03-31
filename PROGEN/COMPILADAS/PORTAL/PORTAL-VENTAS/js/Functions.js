
function  CalcuDesGene(){


  const table = document.getElementById("tablaprueba");
  const rowCount = table.rows.length;

  for (var pd = 1; pd <= rowCount - 1; pd++) {

    ValProd = $("#inputPrecio" + pd + "-ori").val();
    vades = $("#DesGene").val();
    ValDes = ValProd * (vades / 100);
    ValFina=ValProd-ValDes
    $("#inputPrecio" + pd + "").val(ValFina);

    total(pd)

  }


}


function  CalcuDesGeneProd(pd){


    ValProd = $("#inputPrecio" + pd + "-ori").val();
    vades = $("#DesGene").val();
    ValDes = ValProd * (vades / 100);
    ValFina=ValProd-ValDes
    $("#inputPrecio" + pd + "").val(ValFina);


}